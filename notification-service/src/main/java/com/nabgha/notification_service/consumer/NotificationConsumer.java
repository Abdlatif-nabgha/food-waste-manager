package com.nabgha.notification_service.consumer;


import com.nabgha.notification_service.dto.NotificationEvent;
import com.nabgha.notification_service.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationConsumer {

    private final NotificationService notificationService;

    @KafkaListener(topics = "notification-topic", groupId = "${spring.kafka.consumer.group-id:notification-group}")
    public void consume(NotificationEvent event) {
        log.info("Received notification event: {}", event);
        notificationService.processNotification(event);
    }
}
