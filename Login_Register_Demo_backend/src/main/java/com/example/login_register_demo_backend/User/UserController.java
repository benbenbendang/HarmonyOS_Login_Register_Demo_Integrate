package com.example.login_register_demo_backend.User;

import jakarta.validation.constraints.NotBlank;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserRepository repo;

    public UserController(UserRepository repo) {
        this.repo = repo;
    }

    @GetMapping
    public List<User> list() {
        return repo.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> get(@PathVariable Long id) {
        return repo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<User> create(@RequestBody CreateUserReq req) {
        if (repo.existsByUsername(req.username())) {
            return ResponseEntity.badRequest().build();
        }
        User u = new User();
        u.setUsername(req.username());
        u.setEmail(req.email());
        // 这里只是演示：真正密码请走 /api/auth/register 逻辑设置 passwordHash
        u.setPasswordHash("N/A");
        User saved = repo.save(u);
        return ResponseEntity.created(URI.create("/api/users/" + saved.getId())).body(saved);
    }

    @PutMapping("/{id}/email")
    public ResponseEntity<User> updateEmail(@PathVariable Long id, @RequestBody UpdateEmailReq req) {
        return repo.findById(id).map(u -> {
            u.setEmail(req.email());
            return ResponseEntity.ok(repo.save(u));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (!repo.existsById(id)) return ResponseEntity.notFound().build();
        repo.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    public record CreateUserReq(@NotBlank String username, String email) {}
    public record UpdateEmailReq(String email) {}
}
