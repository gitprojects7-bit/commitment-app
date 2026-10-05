package com.commitmentapp.dto;

import java.time.Instant;
import com.commitmentapp.model.Admin;

public record AdminResponse(
        String id,
        String name,
        String email,
        String role,
        String phone,
        Instant lastLogin,
        Instant createdAt,
        Instant updatedAt) {
    public static AdminResponse from(Admin admin) {
        return new AdminResponse(
                admin.getId(), admin.getName(), admin.getEmail(), admin.getRole(),
                admin.getPhone(), admin.getLastLogin(), admin.getCreatedAt(), admin.getUpdatedAt());
    }
}