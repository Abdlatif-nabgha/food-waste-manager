package com.nabgha.product_service.config;

import com.nabgha.product_service.entity.Category;
import com.nabgha.product_service.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

@Component
@RequiredArgsConstructor
public class DatabaseSeeder implements CommandLineRunner {

    private final CategoryRepository categoryRepository;

    @Override
    public void run(String... args) throws Exception {
        if (categoryRepository.count() == 0) {
            List<String> categories = Arrays.asList(
                    "Fruits", "Vegetables", "Dairy", "Meat", "Fish & Seafood",
                    "Bakery", "Drinks", "Frozen Foods", "Snacks", "Canned Foods",
                    "Spices", "Ready Meals"
            );

            categories.forEach(name -> {
                Category category = new Category();
                category.setName(name);
                categoryRepository.save(category);
            });
            
            System.out.println("Categories seeded successfully!");
        }
    }
}
