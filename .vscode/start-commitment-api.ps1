$ErrorActionPreference = 'Stop'

$apiUri = 'http://localhost:8080/api/auth/login'

function Test-CommitmentApi {
    try {
        $body = @{
            email    = "api-healthcheck-$PID@example.invalid"
            password = 'health-check'
        } | ConvertTo-Json -Compress
        $response = Invoke-WebRequest `
            -Uri $apiUri `
            -Method Post `
            -ContentType 'application/json' `
            -Body $body `
            -UseBasicParsing `
            -TimeoutSec 3
        return [int]$response.StatusCode -eq 401
    }
    catch [System.Net.WebException] {
        $response = $_.Exception.Response
        return $null -ne $response -and [int]$response.StatusCode -eq 401
    }
    catch {
        return $false
    }
}

if (Test-CommitmentApi) {
    Write-Output 'Commitment API is already responding on port 8080.'
    exit 0
}

$listener = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue |
    Select-Object -First 1
if ($null -ne $listener) {
    throw "Port 8080 is in use, but it is not the Commitment API. Stop that service or change the API port."
}

$backendPath = Join-Path $PSScriptRoot '..\backend'
$jarPath = Join-Path $backendPath 'target\commitment-admin-api-0.0.1-SNAPSHOT.jar'
if (-not (Test-Path -LiteralPath $jarPath -PathType Leaf)) {
    throw "Backend JAR not found at '$jarPath'. Build the backend before launching the admin web app."
}

$logDirectory = Join-Path $env:LOCALAPPDATA 'CommitmentApp\logs'
New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
$stdoutPath = Join-Path $logDirectory 'admin-api.out.log'
$stderrPath = Join-Path $logDirectory 'admin-api.err.log'
$resolvedJarPath = (Resolve-Path -LiteralPath $jarPath).Path

Write-Output 'Starting Commitment API on port 8080...'
$process = Start-Process `
    -FilePath 'java' `
    -ArgumentList @('-jar', "`"$resolvedJarPath`"") `
    -WorkingDirectory $backendPath `
    -WindowStyle Hidden `
    -RedirectStandardOutput $stdoutPath `
    -RedirectStandardError $stderrPath `
    -PassThru

for ($attempt = 0; $attempt -lt 60; $attempt++) {
    Start-Sleep -Seconds 1

    if (Test-CommitmentApi) {
        Write-Output "Commitment API is ready on port 8080 (PID $($process.Id))."
        exit 0
    }

    $process.Refresh()
    if ($process.HasExited) {
        $errorDetails = if (Test-Path -LiteralPath $stderrPath) {
            Get-Content -LiteralPath $stderrPath -Tail 30 | Out-String
        }
        else {
            'No backend error log was created.'
        }
        throw "Commitment API exited before becoming ready. $errorDetails"
    }
}

throw "Commitment API did not respond on port 8080 within 60 seconds. Check '$stderrPath'."
