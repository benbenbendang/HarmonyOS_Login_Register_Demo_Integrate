package com.example.login_register_demo_backend.auth;

import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.Duration;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class TokenService {
    private static class TokenInfo {
        final Long userId;
        final Instant expireAt;
        TokenInfo(Long userId, Instant expireAt) { this.userId = userId; this.expireAt = expireAt; }
    }

    private final Map<String, TokenInfo> store = new ConcurrentHashMap<>();
    private final Duration ttl = Duration.ofHours(24);

    public String issue(Long userId) {
        String token = UUID.randomUUID().toString().replace("-", "");
        store.put(token, new TokenInfo(userId, Instant.now().plus(ttl)));
        return token;
    }

    public Long verify(String token) {
        if (token == null || token.isEmpty()) return null;
        TokenInfo info = store.get(token);
        if (info == null) return null;
        if (Instant.now().isAfter(info.expireAt)) {
            store.remove(token);
            return null;
        }
        return info.userId;
    }

    public void revoke(String token) { if (token != null) store.remove(token); }
}
