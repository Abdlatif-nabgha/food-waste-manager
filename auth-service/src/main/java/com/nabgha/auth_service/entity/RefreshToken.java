package com.nabgha.auth_service.entity;


import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
@Entity
@Table(name = "refresh_tokens")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class RefreshToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String token;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "expiry_date", nullable = false)
    private LocalDateTime expiryDate;

    @Column(name = "last_used_at")
    private LocalDateTime lastUsedAt;

    public boolean isExpired(){
        return LocalDateTime.now().isAfter(expiryDate);
    }
}
