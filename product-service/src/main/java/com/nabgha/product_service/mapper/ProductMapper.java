package com.nabgha.product_service.mapper;

import com.nabgha.product_service.dto.request.ProductRequest;
import com.nabgha.product_service.dto.response.ProductResponse;
import com.nabgha.product_service.entity.Product;
import com.nabgha.product_service.entity.Category;
import org.mapstruct.*;

@Mapper(componentModel = "spring", nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface ProductMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "category", source = "category")
    @Mapping(target = "userId", source = "userId")
    @Mapping(target = "status", constant = "FRESH")
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "name", source = "request.name")
    @Mapping(target = "quantity", expression = "java(request.quantity() != null ? request.quantity() : 1)")
    @Mapping(target = "expiryDate", source = "request.expiryDate")
    Product toEntity(ProductRequest request, Category category, Long userId);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "userId", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "category", ignore = true)
    @Mapping(target = "status", ignore = true)
    void updateProductFromRequest(ProductRequest request, @MappingTarget Product product);

    @Mapping(target = "categoryName", source = "category.name")
    ProductResponse toResponse(Product product);
}
