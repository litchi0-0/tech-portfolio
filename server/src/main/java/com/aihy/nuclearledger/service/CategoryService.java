package com.aihy.nuclearledger.service;

import com.aihy.nuclearledger.common.AppContext;
import com.aihy.nuclearledger.common.BusinessException;
import com.aihy.nuclearledger.dto.category.CategoryCreateRequest;
import com.aihy.nuclearledger.dto.category.CategoryResponse;
import com.aihy.nuclearledger.dto.category.CategoryUpdateRequest;
import com.aihy.nuclearledger.entity.Category;
import com.aihy.nuclearledger.repository.CategoryRepository;
import com.aihy.nuclearledger.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;
    private final TransactionRepository transactionRepository;

    public List<CategoryResponse> list(Long userId, String type) {
        Long appId = AppContext.getAppId();
        List<Category> categories;
        if (type != null && !type.isBlank()) {
            categories = categoryRepository.findByAppIdAndUserIdAndTypeOrderBySortOrderAsc(appId, userId, type);
        } else {
            categories = categoryRepository.findByAppIdAndUserIdOrderBySortOrderAsc(appId, userId);
        }
        return categories.stream().map(this::toResponse).toList();
    }

    public CategoryResponse create(Long userId, CategoryCreateRequest request) {
        Long appId = AppContext.getAppId();
        if (request.getName() == null || request.getName().isBlank()) {
            throw new BusinessException("分类名称不能为空");
        }
        validateType(request.getType());

        Category category = new Category();
        category.setAppId(appId);
        category.setUserId(userId);
        category.setName(request.getName());
        category.setType(request.getType());
        category.setIcon(request.getIcon());
        category.setColor(request.getColor());
        category.setSortOrder(request.getSortOrder() != null ? request.getSortOrder() : 0);

        category = categoryRepository.save(category);
        return toResponse(category);
    }

    public CategoryResponse update(Long userId, Long id, CategoryUpdateRequest request) {
        Long appId = AppContext.getAppId();
        Category category = findAndCheckOwner(appId, userId, id);

        if (request.getName() != null && !request.getName().isBlank()) {
            category.setName(request.getName());
        }
        if (request.getType() != null) {
            validateType(request.getType());
            category.setType(request.getType());
        }
        if (request.getIcon() != null) {
            category.setIcon(request.getIcon());
        }
        if (request.getColor() != null) {
            category.setColor(request.getColor());
        }
        if (request.getSortOrder() != null) {
            category.setSortOrder(request.getSortOrder());
        }

        category = categoryRepository.save(category);
        return toResponse(category);
    }

    public boolean delete(Long userId, Long id) {
        Long appId = AppContext.getAppId();
        Category category = findAndCheckOwner(appId, userId, id);

        boolean hasTransactions = transactionRepository.exists((root, query, cb) ->
                cb.and(
                        cb.equal(root.get("appId"), appId),
                        cb.equal(root.get("categoryId"), id),
                        cb.equal(root.get("userId"), userId)
                )
        );
        if (hasTransactions) {
            throw new BusinessException("该分类已被账单使用，无法删除");
        }

        categoryRepository.delete(category);
        return true;
    }

    private Category findAndCheckOwner(Long appId, Long userId, Long id) {
        Category c = categoryRepository.findById(id)
                .orElseThrow(() -> new BusinessException("分类不存在"));
        if (!c.getAppId().equals(appId) || !c.getUserId().equals(userId)) {
            throw new BusinessException("无权操作该分类");
        }
        return c;
    }

    private void validateType(String type) {
        if (type == null || (!type.equals("expense") && !type.equals("income"))) {
            throw new BusinessException("type必须是expense或income");
        }
    }

    private CategoryResponse toResponse(Category c) {
        CategoryResponse resp = new CategoryResponse();
        resp.setId(c.getId());
        resp.setName(c.getName());
        resp.setType(c.getType());
        resp.setIcon(c.getIcon());
        resp.setColor(c.getColor());
        resp.setSortOrder(c.getSortOrder());
        resp.setCreatedAt(c.getCreatedAt());
        resp.setUpdatedAt(c.getUpdatedAt());
        return resp;
    }

}
