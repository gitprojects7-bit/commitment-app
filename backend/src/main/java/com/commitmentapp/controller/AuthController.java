package com.commitmentapp.controller;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.commitmentapp.dto.LoginRequest;
import com.commitmentapp.dto.LoginResponse;
import com.commitmentapp.service.AuthService;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthService service;

    public AuthController(AuthService service) {
        this.service = service;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = service.login(request);
        return ResponseEntity.status(response.success() ? HttpStatus.OK : HttpStatus.UNAUTHORIZED)
                .body(response);
    }
}