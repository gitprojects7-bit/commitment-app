package com.commitmentapp.dto;

public record LoginResponse(boolean success, String message, AdminResponse admin) {
    public static LoginResponse success(AdminResponse admin) {
        return new LoginResponse(true, "Login successful", admin);
    }

    public static LoginResponse failure() {
        return new LoginResponse(false, "Invalid email or password", null);
    }
}