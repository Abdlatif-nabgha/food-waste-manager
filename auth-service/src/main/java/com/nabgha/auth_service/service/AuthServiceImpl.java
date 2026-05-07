package com.nabgha.auth_service.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.client.util.Value;
import com.nabgha.auth_service.dto.request.*;
import com.nabgha.auth_service.dto.response.*;
import com.nabgha.auth_service.entity.RefreshToken;
import com.nabgha.auth_service.entity.User;
import com.nabgha.auth_service.enums.AuthProvider;
import com.nabgha.auth_service.repository.RefreshTokenRepository;
import com.nabgha.auth_service.repository.UserRepository;
import com.nabgha.auth_service.security.JwtService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.Random;
import java.util.UUID;
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final EmailService emailService;

    @Value("${google.client-id}")
    private String googleClientId;

    @Override
    @Transactional
    public MessageResponse register(RegisterRequest request) {
        if (userRepository.findByEmail(request.email()).isPresent()) {
            return new MessageResponse("Error: Email already exists!");
        }

        int code = new Random().nextInt(900000) + 100000;
        User user = User.builder()
                .fullName(request.fullName())
                .email(request.email())
                .password(passwordEncoder.encode(request.password()))
                .authProvider(AuthProvider.LOCAL)
                .enabled(false)
                .verificationCode(code)
                .verificationCodeExpiry(LocalDateTime.now().plusMinutes(15))
                .createdAt(LocalDateTime.now())
                .build();

        userRepository.save(user);
        
        emailService.sendVerificationEmail(user.getEmail(), user.getFullName(), code);
        return new MessageResponse("Verification code sent to your email.");
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email(), request.password())
        );

        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!user.isEnabled()) {
            throw new RuntimeException("Please verify your email first.");
        }

        String accessToken = jwtService.generateToken(user);
        String refreshToken = createRefreshToken(user);

        return new AuthResponse(accessToken, refreshToken, user.getEmail(), user.getFullName());
    }

    @Override
    @Transactional
    public MessageResponse verifyEmail(VerifyCodeRequest request) {
        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (user.getVerificationCode() == null || !user.getVerificationCode().equals(request.code())) {
            throw new RuntimeException("Invalid verification code.");
        }

        if (user.getVerificationCodeExpiry().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Verification code expired.");
        }

        user.setEnabled(true);
        user.setVerificationCode(null);
        user.setVerificationCodeExpiry(null);
        userRepository.save(user);

        return new MessageResponse("Email verified successfully. You can now login.");
    }

    @Override
    @Transactional
    public MessageResponse resendCode(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        int code = new Random().nextInt(900000) + 100000;
        user.setVerificationCode(code);
        user.setVerificationCodeExpiry(LocalDateTime.now().plusMinutes(15));
        userRepository.save(user);

        emailService.sendVerificationEmail(user.getEmail(), user.getFullName(), code);

        return new MessageResponse("New verification code sent.");
    }

    @Override
    @Transactional
    public AuthResponse refreshToken(String token) {
        return refreshTokenRepository.findByToken(token)
                .map(rt -> {
                    if (rt.isExpired()) {
                        refreshTokenRepository.delete(rt);
                        throw new RuntimeException("Refresh token expired. Please login again.");
                    }
                    String accessToken = jwtService.generateToken(rt.getUser());
                    rt.setLastUsedAt(LocalDateTime.now());
                    refreshTokenRepository.save(rt);
                    return new AuthResponse(accessToken, token, rt.getUser().getEmail(), rt.getUser().getFullName());
                })
                .orElseThrow(() -> new RuntimeException("Invalid refresh token."));
    }

    @Override
    @Transactional
    public AuthResponse googleLogin(String googleClientId) {
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(),
                    new GsonFactory()
            )
                    .setAudience(Collections.singletonList(googleClientId))
                    .build();

            GoogleIdToken idToken = verifier.verify(googleClientId);

            if (idToken == null) {
                throw new RuntimeException("Invalid Google token.");
            }

            GoogleIdToken.Payload payload = idToken.getPayload();
            String email = payload.getEmail();
            String name = (String) payload.get(email);
            String googleId = payload.getSubject();

            User user = userRepository.findByEmail(email)
                    .orElseGet(() -> {
                        User newUser = User.builder()
                                .email(email)
                                .fullName(name)
                                .googleId(googleId)
                                .password(passwordEncoder.encode(UUID.randomUUID().toString()))
                                .authProvider(AuthProvider.GOOGLE)
                                .enabled(true)
                                .createdAt(LocalDateTime.now())
                                .build();
                        return userRepository.save(newUser);
                    });
            String accessToken = jwtService.generateToken(user);
            String refreshToken = createRefreshToken(user);
            return new AuthResponse(accessToken, refreshToken, user.getEmail(), user.getFullName());

        } catch (Exception e) {
            throw new RuntimeException("Google authentication failed: " + e.getMessage());
        }
    }

    @Override
    @Transactional
    public MessageResponse forgotPassword(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        int code = new Random().nextInt(900000) + 100000;
        user.setResetCode(code);
        user.setResetCodeExpiry(LocalDateTime.now().plusMinutes(15));
        userRepository.save(user);

        emailService.sendResetPasswordEmail(email, code);

        return new MessageResponse("Reset code sent to your email.");
    }

    @Override
    @Transactional
    public MessageResponse resetPassword(ResetPasswordRequest request) {
        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (user.getResetCode() == null || !user.getResetCode().equals(request.code())) {
            throw new RuntimeException("Invalid reset code.");
        }

        if (user.getResetCodeExpiry().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Reset code expired.");
        }

        user.setPassword(passwordEncoder.encode(request.newPassword()));
        user.setResetCode(null);
        user.setResetCodeExpiry(null);
        userRepository.save(user);

        return new MessageResponse("Password reset successfully.");
    }

    private String createRefreshToken(User user) {
        RefreshToken rt = RefreshToken.builder()
                .user(user)
                .token(UUID.randomUUID().toString())
                .expiryDate(LocalDateTime.now().plusMonths(3))
                .lastUsedAt(LocalDateTime.now())
                .build();
        return refreshTokenRepository.save(rt).getToken();
    }
}
