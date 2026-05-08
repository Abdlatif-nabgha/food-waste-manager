package com.nabgha.product_service.scheduler;

import com.nabgha.product_service.entity.Product;
import com.nabgha.product_service.enums.ProductStatus;
import com.nabgha.product_service.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class ProductScheduler {

    private final ProductRepository productRepository;

    @Value("${scheduler.expiry.days-threshold:3}")
    private int daysThreshold;

    @Scheduled(cron = "${scheduler.expiry.cron:0 0 0 * * *}")
    @Transactional
    public void updateProductStatuses() {
        log.info("Starting product status update job...");
        List<Product> products = productRepository.findAll();
        LocalDate today = LocalDate.now();
        LocalDate thresholdDate = today.plusDays(daysThreshold);

        for (Product product : products) {
            if (product.getStatus() == ProductStatus.CONSUMED) {
                continue;
            }

            if (product.getExpiryDate().isBefore(today)) {
                if (product.getStatus() != ProductStatus.EXPIRED) {
                    product.setStatus(ProductStatus.EXPIRED);
                    log.info("Product {} marked as EXPIRED", product.getName());
                }
            } else if (product.getExpiryDate().isBefore(thresholdDate) || product.getExpiryDate().isEqual(today)) {
                if (product.getStatus() != ProductStatus.EXPIRING_SOON) {
                    product.setStatus(ProductStatus.EXPIRING_SOON);
                    log.info("Product {} marked as EXPIRING_SOON", product.getName());
                }
            } else {
                if (product.getStatus() != ProductStatus.FRESH) {
                    product.setStatus(ProductStatus.FRESH);
                }
            }
        }
        productRepository.saveAll(products);
        log.info("Product status update job completed.");
    }
}
