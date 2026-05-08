package com.nabgha.product_service.service;

import com.nabgha.product_service.dto.request.ProductRequest;
import com.nabgha.product_service.dto.response.MessageResponse;
import com.nabgha.product_service.dto.response.ProductResponse;
import com.nabgha.product_service.entity.Category;
import com.nabgha.product_service.entity.Product;
import com.nabgha.product_service.enums.ProductStatus;
import com.nabgha.product_service.mapper.ProductMapper;
import com.nabgha.product_service.repository.CategoryRepository;
import com.nabgha.product_service.repository.ProductRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final CategoryRepository categoryRepository;
    private final ProductRepository productRepository;
    private final ProductMapper productMapper;

    @Override
    @Transactional
    public MessageResponse addProduct(ProductRequest request, Long userId) {
        Category category = categoryRepository.findById(request.categoryId())
                .orElseThrow(() -> new RuntimeException("Category not found"));

        Product product = productMapper.toEntity(request, category, userId);
        productRepository.save(product);
        return new MessageResponse("Product added successfully.");
    }

    @Override
    @Transactional
    public MessageResponse updateProduct(Long id, ProductRequest request, Long userId) {
        Product product = productRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        if (request.categoryId() != null) {
            Category category = categoryRepository.findById(request.categoryId())
                    .orElseThrow(() -> new RuntimeException("Category not found"));
            product.setCategory(category);
        }

        productMapper.updateProductFromRequest(request, product);
        productRepository.save(product);
        
        return new MessageResponse("Product updated successfully.");
    }

    @Override
    @Transactional
    public MessageResponse deleteProduct(Long id, Long userId) {
        Product product = productRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        productRepository.delete(product);

        return new MessageResponse("Product deleted successfully!");
    }

    @Override
    @Transactional
    public MessageResponse consumeProduct(Long id, Long userId) {
        Product product = productRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        product.setStatus(ProductStatus.CONSUMED);
        productRepository.save(product);
        return new MessageResponse("Product marked as consumed.");
    }

    @Override
    public ProductResponse getProduct(Long id, Long userId) {
        Product product = productRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        return productMapper.toResponse(product);
    }

    @Override
    public List<ProductResponse> getAllProducts(Long userId) {
        return productRepository.findByUserId(userId).stream()
                .map(productMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<ProductResponse> getExpiringProduct(Long userId){
        return productRepository.findByUserIdAndStatus(userId, ProductStatus.EXPIRING_SOON)
                .stream()
                .map(productMapper::toResponse)
                .toList();
    }

    @Override
    public List<ProductResponse> getExpiredProducts(Long userId) {
        return productRepository.findByUserIdAndStatus(userId, ProductStatus.EXPIRED)
                .stream()
                .map(productMapper::toResponse)
                .toList();
    }
}
