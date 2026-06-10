package com.aihy.nuclearledger.controller;

import com.aihy.nuclearledger.common.ApiResponse;
import com.aihy.nuclearledger.dto.transaction.TransactionCreateRequest;
import com.aihy.nuclearledger.dto.transaction.TransactionResponse;
import com.aihy.nuclearledger.dto.transaction.TransactionUpdateRequest;
import com.aihy.nuclearledger.service.TransactionService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
public class TransactionController {

    private final TransactionService transactionService;

    @PostMapping
    public ApiResponse<TransactionResponse> create(Authentication authentication,
                                                    @RequestBody TransactionCreateRequest request) {
        return ApiResponse.success(transactionService.create(getUserId(authentication), request));
    }

    @GetMapping
    public ApiResponse<List<TransactionResponse>> list(Authentication authentication,
                                                        @RequestParam(required = false) String type,
                                                        @RequestParam(required = false) Long categoryId,
                                                        @RequestParam(required = false) Long accountId,
                                                        @RequestParam(required = false) String startDate,
                                                        @RequestParam(required = false) String endDate) {
        return ApiResponse.success(transactionService.list(getUserId(authentication), type, categoryId, accountId, startDate, endDate));
    }

    @GetMapping("/{id}")
    public ApiResponse<TransactionResponse> getDetail(Authentication authentication,
                                                       @PathVariable Long id) {
        return ApiResponse.success(transactionService.getDetail(getUserId(authentication), id));
    }

    @PutMapping("/{id}")
    public ApiResponse<TransactionResponse> update(Authentication authentication,
                                                    @PathVariable Long id,
                                                    @RequestBody TransactionUpdateRequest request) {
        return ApiResponse.success(transactionService.update(getUserId(authentication), id, request));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Boolean> delete(Authentication authentication,
                                        @PathVariable Long id) {
        return ApiResponse.success(transactionService.delete(getUserId(authentication), id));
    }

    private Long getUserId(Authentication authentication) {
        return Long.parseLong(authentication.getName());
    }

}
