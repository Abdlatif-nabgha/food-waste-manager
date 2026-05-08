package com.nabgha.product_service.controller;

import com.nabgha.product_service.dto.request.CategoryRequest;
import com.nabgha.product_service.dto.response.CategoryResponse;
import com.nabgha.product_service.dto.response.MessageResponse;
import com.nabgha.product_service.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;

    @PostMapping
    public ResponseEntity<MessageResponse> addCategory(@RequestBody CategoryRequest request) {
        return ResponseEntity.ok(categoryService.addCategory(request));
    }

    @GetMapping
    public ResponseEntity<List<CategoryResponse>> getAllCategories() {
        return ResponseEntity.ok(categoryService.getAllCategory());
    }
}
