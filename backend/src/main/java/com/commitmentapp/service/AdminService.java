package com.commitmentapp.service;

import java.time.Instant;
import java.util.Locale;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import com.commitmentapp.dto.AdminResponse;
import com.commitmentapp.dto.AdminUpdateRequest;
import com.commitmentapp.dto.SignupRequest;
import com.commitmentapp.exception.AdminNotFoundException;
import com.commitmentapp.exception.DuplicateAdminException;
import com.commitmentapp.model.Admin;
import com.commitmentapp.repository.AdminRepository;

@Service
public class AdminService {
    private final AdminRepository repository;
    private final PasswordEncoder passwordEncoder;

    public AdminService(AdminRepository repository, PasswordEncoder passwordEncoder) {
        this.repository = repository;
        this.passwordEncoder = passwordEncoder;
    }

    public AdminResponse signup(SignupRequest request) {
        String email = normalizeEmail(request.email());
        if (repository.existsByEmail(email)) throw new DuplicateAdminException();

        Instant now = Instant.now();
        Admin admin = new Admin();
        admin.setName(request.name().trim());
        admin.setEmail(email);
        admin.setPassword(passwordEncoder.encode(request.password()));
        admin.setRole(request.role().trim());
        admin.setPhone(request.phone().trim());
        admin.setCreatedAt(now);
        admin.setUpdatedAt(now);
        try {
            return AdminResponse.from(repository.save(admin));
        } catch (DuplicateKeyException exception) {
            throw new DuplicateAdminException();
        }
    }

    public Admin findByEmail(String email) {
        return repository.findByEmail(normalizeEmail(email)).orElse(null);
    }

    public AdminResponse getById(String id) {
        return AdminResponse.from(findById(id));
    }

    public AdminResponse update(String id, AdminUpdateRequest request) {
        Admin admin = findById(id);
        if (request.name() != null) admin.setName(request.name().trim());
        if (request.email() != null) {
            String email = normalizeEmail(request.email());
            if (!email.equals(admin.getEmail()) && repository.existsByEmail(email)) {
                throw new DuplicateAdminException();
            }
            admin.setEmail(email);
        }
        if (request.phone() != null) admin.setPhone(request.phone().trim());
        if (request.role() != null) admin.setRole(request.role().trim());
        admin.setUpdatedAt(Instant.now());
        try {
            return AdminResponse.from(repository.save(admin));
        } catch (DuplicateKeyException exception) {
            throw new DuplicateAdminException();
        }
    }

    public AdminResponse loginSuccess(Admin admin) {
        Instant now = Instant.now();
        admin.setLastLogin(now);
        admin.setUpdatedAt(now);
        return AdminResponse.from(repository.save(admin));
    }

    private Admin findById(String id) {
        return repository.findById(id).orElseThrow(AdminNotFoundException::new);
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }
}