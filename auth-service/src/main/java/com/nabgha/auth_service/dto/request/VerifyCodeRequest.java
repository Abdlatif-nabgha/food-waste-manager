package com.nabgha.auth_service.dto.request;


public record VerifyCodeRequest(String email, Integer code){}
