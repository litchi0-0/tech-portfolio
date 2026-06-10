package com.aihy.nuclearledger.controller;

import com.aihy.nuclearledger.common.ApiResponse;
import com.aihy.nuclearledger.dto.user.UserResponse;
import com.aihy.nuclearledger.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ApiResponse<UserResponse> getCurrentUser(Authentication authentication) {
        Long userId = getUserId(authentication);
        return ApiResponse.success(userService.getCurrentUser(userId));
    }

    private Long getUserId(Authentication authentication) {
        return Long.parseLong(authentication.getName());
    }

}
