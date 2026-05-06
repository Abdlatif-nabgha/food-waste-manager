package com.nabgha.auth_service.dto.request;


public record ResetPasswordRequest(String email, Integer code, String newPassword){}
