# Commitment Admin Backend

This Spring Boot API stores only administrator accounts in MongoDB database `commitment_app`, collection `admins`.

## Requirements

- Java 17+
- Maven 3.9+
- MongoDB running on `localhost:27017` (the MongoDB Compass connection shown in the project screenshot is suitable)

The database and collection are created when the first admin is registered. Passwords are stored as BCrypt hashes and are never returned by the API. MongoDB connection values are configurable through environment variables.

## Start the backend

From this folder:

```powershell
mvn spring-boot:run
```

Defaults are `mongodb://localhost:27017/commitment_app` and HTTP port `8080`. To override the MongoDB URI:

```powershell
$env:MONGODB_URI = 'mongodb://localhost:27017/commitment_app'
$env:MONGODB_DATABASE = 'commitment_app'
mvn spring-boot:run
```

If MongoDB is not already running as a Windows service, start the MongoDB Server service before starting Spring Boot. Do not connect Flutter directly to MongoDB.

## Test with Postman

1. Signup: `POST http://localhost:8080/api/admin/signup`

```json
{
  "name": "Admin",
  "email": "admin@example.com",
  "password": "password123",
  "role": "Super Admin",
  "phone": "+91 9876543210"
}
```

A successful signup returns `201 Created`, the generated `id`, and the profile fields, but no password. A duplicate email returns `409 Conflict`.

2. Login: `POST http://localhost:8080/api/auth/login`

```json
{
  "email": "admin@example.com",
  "password": "password123"
}
```

Success returns the admin ID and profile. Incorrect credentials return `401`.

3. Profile: `GET http://localhost:8080/api/admin/{id}` using the ID returned by login.

4. Optional profile update: `PUT http://localhost:8080/api/admin/{id}` with any supplied `name`, `email`, `role`, or `phone` fields. Password changes are deliberately excluded.

In MongoDB Compass, refresh and open `commitment_app` > `admins`. The `password` field is a BCrypt hash.

## Run Flutter Admin

The existing admin Flutter project is `../admin_backup`.

```powershell
cd ..\admin_backup
flutter pub get
flutter run -d chrome --web-port 53120 --dart-define=API_BASE_URL=http://localhost:8080
```

For Android emulator use `--dart-define=API_BASE_URL=http://10.0.2.2:8080`. A physical Android device must use the development computer's LAN address, for example `http://192.168.1.20:8080`.

The login screen contains a signup mode. After signup, sign in with that account; the returned admin ID is stored locally and the dashboard profile is fetched from MongoDB through the API. No dashboard statistics or user/commitment data are persisted by this backend.

CORS allows only `localhost` and `127.0.0.1` browser origins on any development port by default, so Flutter's automatically selected Chrome port works. Override this with `CORS_ALLOWED_ORIGIN_PATTERNS`, a comma-separated list of trusted origin patterns; restrict it to exact production origins before deployment. Profile endpoints currently use admin IDs and are not protected by an authenticated session; add authorization before production use.
