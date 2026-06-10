package com.aihy.nuclearledger.controller;

import com.aihy.nuclearledger.common.ApiResponse;
import com.aihy.nuclearledger.dto.auth.LoginRequest;
import com.aihy.nuclearledger.dto.auth.LoginResponse;
import com.aihy.nuclearledger.dto.auth.RegisterRequest;
import com.aihy.nuclearledger.dto.user.UserResponse;
import com.aihy.nuclearledger.entity.App;
import com.aihy.nuclearledger.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ApiResponse<UserResponse> register(@RequestHeader("X-App-Key") String appKey,
                                               @RequestBody RegisterRequest request) {
        App app = authService.resolveApp(appKey);
        return ApiResponse.success(authService.register(app.getId(), request));
    }

    @PostMapping("/login")
    public ApiResponse<LoginResponse> login(@RequestHeader("X-App-Key") String appKey,
                                             @RequestBody LoginRequest request) {
        App app = authService.resolveApp(appKey);
        return ApiResponse.success(authService.login(app.getId(), request));
    }

}
