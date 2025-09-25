package com.example.login_register_demo_backend.auth.dto;

import jakarta.validation.constraints.NotBlank;

public class AuthDtos {
    public record RegisterReq(@NotBlank String username, @NotBlank String password, String email) {}
    public record LoginReq(@NotBlank String username, @NotBlank String password) {}
    public record ForgotReq(@NotBlank String username, @NotBlank String newPassword) {}
    public record LoginResp(String token, String username) {}
    public record MeResp(Long id, String username, String email) {}
}
