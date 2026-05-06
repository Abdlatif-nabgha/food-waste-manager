package com.nabgha.auth_service.dto.response;


public record AuthResponse(String accessToken, String refreshToken, String email, String fullName){}
