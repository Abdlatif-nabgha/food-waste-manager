package com.nabgha.product_service.service;

import com.nabgha.product_service.dto.request.ProductRequest;
import com.nabgha.product_service.dto.response.MessageResponse;
import com.nabgha.product_service.dto.response.ProductResponse;

import java.util.List;

public interface ProductService {
    MessageResponse addProduct(ProductRequest request, Long userId);
    MessageResponse updateProduct(Long id, ProductRequest request, Long userId);
    MessageResponse deleteProduct(Long id, Long userId);
    MessageResponse consumeProduct(Long id, Long userId);
    ProductResponse getProduct(Long id, Long userId);
    List<ProductResponse> getAllProducts(Long userId);

    List<ProductResponse> getExpiringProduct(Long userId);

    List<ProductResponse> getExpiredProducts(Long userId);
}
