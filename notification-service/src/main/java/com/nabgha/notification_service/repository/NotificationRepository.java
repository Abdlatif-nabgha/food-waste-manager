package com.nabgha.notification_service.repository;


import com.nabgha.notification_service.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByUserIdOrderByCreatedAt(Long userId);

    long countByUserIdAndIsReadFalse(Long userId, boolean isRead);
}
