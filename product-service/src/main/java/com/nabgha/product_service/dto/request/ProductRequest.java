package com.nabgha.product_service.dto.request;

import java.time.LocalDate;

public record ProductRequest(
    String name,
    Integer quantity,
    LocalDate expiryDate,
    Long categoryId
) {}
