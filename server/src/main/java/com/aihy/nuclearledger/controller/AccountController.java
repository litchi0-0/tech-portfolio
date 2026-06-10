package com.aihy.nuclearledger.controller;

import com.aihy.nuclearledger.common.ApiResponse;
import com.aihy.nuclearledger.dto.account.AccountCreateRequest;
import com.aihy.nuclearledger.dto.account.AccountResponse;
import com.aihy.nuclearledger.dto.account.AccountUpdateRequest;
import com.aihy.nuclearledger.service.AccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/accounts")
@RequiredArgsConstructor
public class AccountController {

    private final AccountService accountService;

    @GetMapping
    public ApiResponse<List<AccountResponse>> list(Authentication authentication) {
        return ApiResponse.success(accountService.list(getUserId(authentication)));
    }

    @PostMapping
    public ApiResponse<AccountResponse> create(Authentication authentication,
                                                @RequestBody AccountCreateRequest request) {
        return ApiResponse.success(accountService.create(getUserId(authentication), request));
    }

    @PutMapping("/{id}")
    public ApiResponse<AccountResponse> update(Authentication authentication,
                                                @PathVariable Long id,
                                                @RequestBody AccountUpdateRequest request) {
        return ApiResponse.success(accountService.update(getUserId(authentication), id, request));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Boolean> delete(Authentication authentication,
                                        @PathVariable Long id) {
        return ApiResponse.success(accountService.delete(getUserId(authentication), id));
    }

    private Long getUserId(Authentication authentication) {
        return Long.parseLong(authentication.getName());
    }

}
