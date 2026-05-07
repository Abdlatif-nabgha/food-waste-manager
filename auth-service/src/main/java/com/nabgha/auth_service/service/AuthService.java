package com.nabgha.auth_service.service;

import com.nabgha.auth_service.dto.request.*;
import com.nabgha.auth_service.dto.response.*;

public interface AuthService {
    MessageResponse register(RegisterRequest request);
    AuthResponse login(LoginRequest request);
    MessageResponse verifyEmail(VerifyCodeRequest request);
    MessageResponse resendCode(String email);
    AuthResponse refreshToken(String refreshToken);
    AuthResponse googleLogin(String googleIdToken);
    MessageResponse forgotPassword(String email);
    MessageResponse resetPassword(ResetPasswordRequest request);
}
