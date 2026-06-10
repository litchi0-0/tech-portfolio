package com.aihy.nuclearledger.controller;

import com.aihy.nuclearledger.common.ApiResponse;
import com.aihy.nuclearledger.dto.budget.BudgetCreateRequest;
import com.aihy.nuclearledger.dto.budget.BudgetResponse;
import com.aihy.nuclearledger.dto.budget.BudgetUpdateRequest;
import com.aihy.nuclearledger.service.BudgetService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/budgets")
@RequiredArgsConstructor
public class BudgetController {

    private final BudgetService budgetService;

    @GetMapping
    public ApiResponse<List<BudgetResponse>> list(Authentication authentication,
                                                   @RequestParam(required = false) String month) {
        return ApiResponse.success(budgetService.list(getUserId(authentication), month));
    }

    @PostMapping
    public ApiResponse<BudgetResponse> create(Authentication authentication,
                                               @RequestBody BudgetCreateRequest request) {
        return ApiResponse.success(budgetService.create(getUserId(authentication), request));
    }

    @PutMapping("/{id}")
    public ApiResponse<BudgetResponse> update(Authentication authentication,
                                               @PathVariable Long id,
                                               @RequestBody BudgetUpdateRequest request) {
        return ApiResponse.success(budgetService.update(getUserId(authentication), id, request));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Boolean> delete(Authentication authentication,
                                        @PathVariable Long id) {
        return ApiResponse.success(budgetService.delete(getUserId(authentication), id));
    }

    private Long getUserId(Authentication authentication) {
        return Long.parseLong(authentication.getName());
    }

}
