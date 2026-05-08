package com.nabgha.product_service.service;

import com.nabgha.product_service.dto.request.CategoryRequest;
import com.nabgha.product_service.dto.response.CategoryResponse;
import com.nabgha.product_service.dto.response.MessageResponse;
import com.nabgha.product_service.entity.Category;
import com.nabgha.product_service.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;

    @Override
    public MessageResponse addCategory(CategoryRequest request) {
        if (categoryRepository.findByName(request.name()).isPresent()) {
            throw new RuntimeException("Category already exists.");
        }
        categoryRepository.save(Category.builder().name(request.name()).build());
        return new MessageResponse("Category added successfully.");
    }

    @Override
    public List<CategoryResponse> getAllCategory() {
        return categoryRepository.findAll()
                .stream()
                .map(category -> new CategoryResponse(category.getId(), category.getName()))
                .toList();
    }
}
