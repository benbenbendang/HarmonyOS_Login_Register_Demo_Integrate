package com.example.login_register_demo_backend.auth;

import com.example.login_register_demo_backend.auth.dto.AuthDtos.*;
import com.example.login_register_demo_backend.common.ApiResponse;
import com.example.login_register_demo_backend.User.User;
import com.example.login_register_demo_backend.User.UserRepository;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserRepository userRepo;
    private final TokenService tokenService;

    public AuthController(UserRepository userRepo, TokenService tokenService) {
        this.userRepo = userRepo;
        this.tokenService = tokenService;
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody @Valid RegisterReq req) {
        if (userRepo.existsByUsername(req.username())) {
            return ResponseEntity.badRequest().body(ApiResponse.fail("用户名已存在"));
        }
        User u = new User();
        u.setUsername(req.username());
        u.setPasswordHash(BCrypt.hashpw(req.password(), BCrypt.gensalt()));
        u.setEmail(req.email());
        userRepo.save(u);
        return ResponseEntity.ok(ApiResponse.ok("注册成功"));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody @Valid LoginReq req) {
        Optional<User> ou = userRepo.findByUsername(req.username());
        if (ou.isEmpty()) return ResponseEntity.badRequest().body(ApiResponse.fail("用户名或密码错误"));
        User u = ou.get();
        if (!BCrypt.checkpw(req.password(), u.getPasswordHash())) {
            return ResponseEntity.badRequest().body(ApiResponse.fail("用户名或密码错误"));
        }
        String token = tokenService.issue(u.getId());
        return ResponseEntity.ok(ApiResponse.ok(new LoginResp(token, u.getUsername())));
    }

    @PostMapping("/forgot")
    public ResponseEntity<?> forgot(@RequestBody @Valid ForgotReq req) {
        Optional<User> ou = userRepo.findByUsername(req.username());
        if (ou.isEmpty()) return ResponseEntity.badRequest().body(ApiResponse.fail("用户不存在"));
        User u = ou.get();
        u.setPasswordHash(BCrypt.hashpw(req.newPassword(), BCrypt.gensalt()));
        userRepo.save(u);
        return ResponseEntity.ok(ApiResponse.ok("密码已重置"));
    }

    @GetMapping("/me")
    public ResponseEntity<?> me(@RequestHeader(HttpHeaders.AUTHORIZATION) String authz) {
        String token = parseBearer(authz);
        Long uid = tokenService.verify(token);
        if (uid == null) return ResponseEntity.status(401).body(ApiResponse.fail("未授权"));
        User u = userRepo.findById(uid).orElse(null);
        if (u == null) return ResponseEntity.status(401).body(ApiResponse.fail("未授权"));
        return ResponseEntity.ok(ApiResponse.ok(new MeResp(u.getId(), u.getUsername(), u.getEmail())));
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout(@RequestHeader(HttpHeaders.AUTHORIZATION) String authz) {
        tokenService.revoke(parseBearer(authz));
        return ResponseEntity.ok(ApiResponse.ok("已退出"));
    }

    private String parseBearer(String authz) {
        if (authz == null) return null;
        if (authz.startsWith("Bearer ")) return authz.substring("Bearer ".length());
        return authz;
    }
}
