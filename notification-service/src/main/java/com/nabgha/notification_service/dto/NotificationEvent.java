package com.nabgha.notification_service.dto;

public record NotificationEvent (
    Long userId,
    String title,
    String message
) {}
