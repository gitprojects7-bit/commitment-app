package com.commitmentapp.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record AdminUpdateRequest(
        @Pattern(regexp = ".*\\S.*") @Size(max = 100) String name,
        @Email @Pattern(regexp = ".*\\S.*") @Size(max = 254) String email,
        @Pattern(regexp = "^[+0-9() .-]{7,25}$") String phone,
        @Pattern(regexp = ".*\\S.*") @Size(max = 60) String role) {
}