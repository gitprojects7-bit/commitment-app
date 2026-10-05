package com.commitmentapp.exception;

public class DuplicateAdminException extends RuntimeException {
    public DuplicateAdminException() {
        super("Admin with this email already exists.");
    }
}