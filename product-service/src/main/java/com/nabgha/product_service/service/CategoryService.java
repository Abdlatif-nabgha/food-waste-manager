package com.nabgha.product_service.service;


import com.nabgha.product_service.dto.request.CategoryRequest;
import com.nabgha.product_service.dto.response.CategoryResponse;
import com.nabgha.product_service.dto.response.MessageResponse;

import java.util.List;

public interface CategoryService {

    MessageResponse addCategory(CategoryRequest request);

    List<CategoryResponse> getAllCategory();
}
