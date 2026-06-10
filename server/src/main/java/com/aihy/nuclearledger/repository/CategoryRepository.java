package com.aihy.nuclearledger.repository;

import com.aihy.nuclearledger.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CategoryRepository extends JpaRepository<Category, Long> {

    List<Category> findByAppIdAndUserIdOrderBySortOrderAsc(Long appId, Long userId);

    List<Category> findByAppIdAndUserIdAndTypeOrderBySortOrderAsc(Long appId, Long userId, String type);

}
