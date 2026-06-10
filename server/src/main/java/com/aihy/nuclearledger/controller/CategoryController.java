package com.aihy.nuclearledger.controller;

import com.aihy.nuclearledger.common.ApiResponse;
import com.aihy.nuclearledger.dto.category.CategoryCreateRequest;
import com.aihy.nuclearledger.dto.category.CategoryResponse;
import com.aihy.nuclearledger.dto.category.CategoryUpdateRequest;
import com.aihy.nuclearledger.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;

    @GetMapping
    public ApiResponse<List<CategoryResponse>> list(Authentication authentication,
                                                     @RequestParam(required = false) String type) {
        return ApiResponse.success(categoryService.list(getUserId(authentication), type));
    }

    @PostMapping
    public ApiResponse<CategoryResponse> create(Authentication authentication,
                                                 @RequestBody CategoryCreateRequest request) {
        return ApiResponse.success(categoryService.create(getUserId(authentication), request));
    }

    @PutMapping("/{id}")
    public ApiResponse<CategoryResponse> update(Authentication authentication,
                                                 @PathVariable Long id,
                                                 @RequestBody CategoryUpdateRequest request) {
        return ApiResponse.success(categoryService.update(getUserId(authentication), id, request));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Boolean> delete(Authentication authentication,
                                        @PathVariable Long id) {
        return ApiResponse.success(categoryService.delete(getUserId(authentication), id));
    }

    private Long getUserId(Authentication authentication) {
        return Long.parseLong(authentication.getName());
    }

}
