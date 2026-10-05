package com.commitmentapp.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import com.commitmentapp.dto.AdminResponse;
import com.commitmentapp.dto.LoginRequest;
import com.commitmentapp.dto.LoginResponse;
import com.commitmentapp.model.Admin;

@Service
public class AuthService {
    private final AdminService adminService;
    private final PasswordEncoder passwordEncoder;

    public AuthService(AdminService adminService, PasswordEncoder passwordEncoder) {
        this.adminService = adminService;
        this.passwordEncoder = passwordEncoder;
    }

    public LoginResponse login(LoginRequest request) {
        Admin admin = adminService.findByEmail(request.email());
        if (admin == null || !passwordEncoder.matches(request.password(), admin.getPassword())) {
            return LoginResponse.failure();
        }
        AdminResponse response = adminService.loginSuccess(admin);
        return LoginResponse.success(response);
    }
}