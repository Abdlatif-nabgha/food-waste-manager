package com.nabgha.product_service.repository;

import com.nabgha.product_service.entity.Product;
import com.nabgha.product_service.enums.ProductStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByUserId(Long userId);
    Optional<Product> findByIdAndUserId(Long id, Long userId);
    List<Product> findByUserIdAndStatus(Long userId, ProductStatus status);
}
