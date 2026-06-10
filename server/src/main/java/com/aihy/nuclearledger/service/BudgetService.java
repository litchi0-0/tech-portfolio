package com.aihy.nuclearledger.service;

import com.aihy.nuclearledger.common.AppContext;
import com.aihy.nuclearledger.common.BusinessException;
import com.aihy.nuclearledger.dto.budget.BudgetCreateRequest;
import com.aihy.nuclearledger.dto.budget.BudgetResponse;
import com.aihy.nuclearledger.dto.budget.BudgetUpdateRequest;
import com.aihy.nuclearledger.entity.Budget;
import com.aihy.nuclearledger.entity.Category;
import com.aihy.nuclearledger.repository.BudgetRepository;
import com.aihy.nuclearledger.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BudgetService {

    private final BudgetRepository budgetRepository;
    private final CategoryRepository categoryRepository;

    public List<BudgetResponse> list(Long userId, String month) {
        Long appId = AppContext.getAppId();
        List<Budget> budgets;
        if (month != null && !month.isBlank()) {
            budgets = budgetRepository.findByAppIdAndUserIdAndMonthOrderByMonthDesc(appId, userId, month);
        } else {
            budgets = budgetRepository.findByAppIdAndUserIdOrderByMonthDesc(appId, userId);
        }
        return budgets.stream().map(this::toResponse).toList();
    }

    public BudgetResponse create(Long userId, BudgetCreateRequest request) {
        Long appId = AppContext.getAppId();
        if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new BusinessException("预算金额必须大于0");
        }
        if (request.getMonth() == null || !request.getMonth().matches("\\d{4}-\\d{2}")) {
            throw new BusinessException("month格式必须为yyyy-MM");
        }

        if (request.getCategoryId() != null) {
            Category category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new BusinessException("分类不存在"));
            if (!category.getAppId().equals(appId) || !category.getUserId().equals(userId)) {
                throw new BusinessException("无权操作该分类");
            }
        }

        Budget budget = new Budget();
        budget.setAppId(appId);
        budget.setUserId(userId);
        budget.setCategoryId(request.getCategoryId());
        budget.setAmount(request.getAmount());
        budget.setMonth(request.getMonth());

        budget = budgetRepository.save(budget);
        return toResponse(budget);
    }

    public BudgetResponse update(Long userId, Long id, BudgetUpdateRequest request) {
        Long appId = AppContext.getAppId();
        Budget budget = findAndCheckOwner(appId, userId, id);

        if (request.getCategoryId() != null) {
            Category category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new BusinessException("分类不存在"));
            if (!category.getAppId().equals(appId) || !category.getUserId().equals(userId)) {
                throw new BusinessException("无权操作该分类");
            }
            budget.setCategoryId(request.getCategoryId());
        } else {
            budget.setCategoryId(null);
        }

        if (request.getAmount() != null) {
            if (request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
                throw new BusinessException("预算金额必须大于0");
            }
            budget.setAmount(request.getAmount());
        }
        if (request.getMonth() != null) {
            if (!request.getMonth().matches("\\d{4}-\\d{2}")) {
                throw new BusinessException("month格式必须为yyyy-MM");
            }
            budget.setMonth(request.getMonth());
        }

        budget = budgetRepository.save(budget);
        return toResponse(budget);
    }

    public boolean delete(Long userId, Long id) {
        Long appId = AppContext.getAppId();
        Budget budget = findAndCheckOwner(appId, userId, id);
        budgetRepository.delete(budget);
        return true;
    }

    private Budget findAndCheckOwner(Long appId, Long userId, Long id) {
        Budget b = budgetRepository.findById(id)
                .orElseThrow(() -> new BusinessException("预算不存在"));
        if (!b.getAppId().equals(appId) || !b.getUserId().equals(userId)) {
            throw new BusinessException("无权操作该预算");
        }
        return b;
    }

    private BudgetResponse toResponse(Budget b) {
        BudgetResponse resp = new BudgetResponse();
        resp.setId(b.getId());
        resp.setCategoryId(b.getCategoryId());
        resp.setAmount(b.getAmount());
        resp.setMonth(b.getMonth());
        resp.setCreatedAt(b.getCreatedAt());
        resp.setUpdatedAt(b.getUpdatedAt());

        if (b.getCategoryId() != null) {
            categoryRepository.findById(b.getCategoryId()).ifPresent(c -> resp.setCategoryName(c.getName()));
        }

        return resp;
    }

}
