package com.nabgha.notification_service.service;

import com.nabgha.notification_service.dto.NotificationEvent;
import com.nabgha.notification_service.entity.Notification;
import com.nabgha.notification_service.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository repository;

    public void processNotification(NotificationEvent event) {
        Notification notification = Notification.builder()
                .userId(event.userId())
                .title(event.title())
                .message(event.message())
                .isRead(false)
                .build();
        repository.save(notification);
    }

    public List<Notification> getUserNotifications(Long userId) {
        return repository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public void markAsRead(Long notificationId) {
        repository.findById(notificationId)
                .ifPresent(n -> {
                    n.setRead(true);
                    repository.save(n);
                });
    }

    public long getUnreadCount(Long userId) {
        return repository.countByUserIdAndIsReadFalse(userId);
    }
}

