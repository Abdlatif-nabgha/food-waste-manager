package com.nabgha.product_service.dto.response;

import com.nabgha.product_service.enums.ProductStatus;
import java.time.LocalDate;
import java.time.LocalDateTime;

public record ProductResponse(
    Long id,
    String name,
    int quantity,
    LocalDate expiryDate,
    ProductStatus status,
    String categoryName,
    Long userId,
    LocalDateTime createdAt
) {}
