package com.nabgha.product_service.controller;

import com.nabgha.product_service.dto.request.ProductRequest;
import com.nabgha.product_service.dto.response.MessageResponse;
import com.nabgha.product_service.dto.response.ProductResponse;
import com.nabgha.product_service.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @PostMapping("/{userId}")
    public ResponseEntity<MessageResponse> addProduct(
            @RequestBody ProductRequest request,
            @PathVariable Long userId) {
        return ResponseEntity.ok(productService.addProduct(request, userId));
    }

    @PutMapping("/{id}/user/{userId}")
    public ResponseEntity<MessageResponse> updateProduct(
            @PathVariable Long id,
            @RequestBody ProductRequest request,
            @PathVariable Long userId) {
        return ResponseEntity.ok(productService.updateProduct(id, request, userId));
    }

    @DeleteMapping("/{id}/user/{userId}")
    public ResponseEntity<MessageResponse> deleteProduct(
            @PathVariable Long id,
            @PathVariable Long userId) {
        return ResponseEntity.ok(productService.deleteProduct(id, userId));
    }

    @PatchMapping("/{id}/consume/user/{userId}")
    public ResponseEntity<MessageResponse> consumeProduct(
            @PathVariable Long id,
            @PathVariable Long userId) {
        return ResponseEntity.ok(productService.consumeProduct(id, userId));
    }

    @GetMapping("/{id}/user/{userId}")
    public ResponseEntity<ProductResponse> getProduct(
            @PathVariable Long id,
            @PathVariable Long userId) {
        return ResponseEntity.ok(productService.getProduct(id, userId));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<ProductResponse>> getAllProducts(@PathVariable Long userId) {
        return ResponseEntity.ok(productService.getAllProducts(userId));
    }

    @GetMapping("/expiring/user/{userId}")
    public ResponseEntity<List<ProductResponse>> getExpiringProduct(@PathVariable Long userId) {
        return ResponseEntity.ok(productService.getExpiringProduct(userId));
    }

    @GetMapping("/expired/user/{userId}")
    public ResponseEntity<List<ProductResponse>> getExpiredProducts(@PathVariable Long userId) {
        return ResponseEntity.ok(productService.getExpiredProducts(userId));
    }
}
