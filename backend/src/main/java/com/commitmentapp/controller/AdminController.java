package com.commitmentapp.controller;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.commitmentapp.dto.AdminResponse;
import com.commitmentapp.dto.AdminUpdateRequest;
import com.commitmentapp.dto.SignupRequest;
import com.commitmentapp.service.AdminService;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
    private final AdminService service;

    public AdminController(AdminService service) {
        this.service = service;
    }

    @PostMapping("/signup")
    public ResponseEntity<AdminResponse> signup(@Valid @RequestBody SignupRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.signup(request));
    }

    @GetMapping("/{id}")
    public AdminResponse getById(@PathVariable String id) {
        return service.getById(id);
    }

    @PutMapping("/{id}")
    public AdminResponse update(@PathVariable String id, @Valid @RequestBody AdminUpdateRequest request) {
        return service.update(id, request);
    }
}