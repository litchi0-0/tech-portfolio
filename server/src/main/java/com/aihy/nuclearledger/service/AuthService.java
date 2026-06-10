package com.aihy.nuclearledger.service;

import com.aihy.nuclearledger.common.AppContext;
import com.aihy.nuclearledger.common.BusinessException;
import com.aihy.nuclearledger.dto.auth.LoginRequest;
import com.aihy.nuclearledger.dto.auth.LoginResponse;
import com.aihy.nuclearledger.dto.auth.RegisterRequest;
import com.aihy.nuclearledger.dto.user.UserResponse;
import com.aihy.nuclearledger.entity.Account;
import com.aihy.nuclearledger.entity.App;
import com.aihy.nuclearledger.entity.Category;
import com.aihy.nuclearledger.entity.User;
import com.aihy.nuclearledger.repository.*;
import com.aihy.nuclearledger.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AppRepository appRepository;
    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;
    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    /**
     * Resolve appKey header to App entity. Throw if invalid.
     */
    public App resolveApp(String appKey) {
        if (appKey == null || appKey.isBlank()) {
            throw new BusinessException("X-App-Key 请求头不能为空");
        }
        return appRepository.findByAppKey(appKey)
                .orElseThrow(() -> new BusinessException("无效的 X-App-Key"));
    }

    @Transactional
    public UserResponse register(Long appId, RegisterRequest request) {
        if (request.getUsername() == null || request.getUsername().isBlank()) {
            throw new BusinessException("username不能为空");
        }
        if (request.getPassword() == null || request.getPassword().length() < 6) {
            throw new BusinessException("password不能为空且至少6位");
        }
        if (userRepository.existsByUsernameAndAppId(request.getUsername(), appId)) {
            throw new BusinessException("username已存在");
        }

        User user = new User();
        user.setAppId(appId);
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setNickname(request.getNickname());
        user.setStatus(1);
        user = userRepository.save(user);

        createDefaultCategories(appId, user.getId());
        createDefaultAccount(appId, user.getId());

        return toUserResponse(user);
    }

    public LoginResponse login(Long appId, LoginRequest request) {
        if (request.getUsername() == null || request.getUsername().isBlank()) {
            throw new BusinessException("username不能为空");
        }
        if (request.getPassword() == null || request.getPassword().isBlank()) {
            throw new BusinessException("password不能为空");
        }

        User user = userRepository.findByUsernameAndAppId(request.getUsername(), appId)
                .orElseThrow(() -> new BusinessException("用户名或密码错误"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }

        if (user.getStatus() == 0) {
            throw new BusinessException("账号已被禁用");
        }

        String token = jwtUtil.generateToken(user.getId(), appId, user.getUsername());

        LoginResponse response = new LoginResponse();
        response.setToken(token);
        response.setUser(toUserResponse(user));
        return response;
    }

    private void createDefaultCategories(Long appId, Long userId) {
        List<Category> defaults = List.of(
                createCategory(appId, userId, "餐饮", "expense", "food", "#FF6B6B", 1),
                createCategory(appId, userId, "交通", "expense", "transport", "#4ECDC4", 2),
                createCategory(appId, userId, "购物", "expense", "shopping", "#FF9F43", 3),
                createCategory(appId, userId, "娱乐", "expense", "entertainment", "#A29BFE", 4),
                createCategory(appId, userId, "住房", "expense", "housing", "#FD79A8", 5),
                createCategory(appId, userId, "医疗", "expense", "medical", "#00B894", 6),
                createCategory(appId, userId, "教育", "expense", "education", "#6C5CE7", 7),
                createCategory(appId, userId, "其他", "expense", "other_expense", "#636E72", 8),
                createCategory(appId, userId, "工资", "income", "salary", "#00B894", 1),
                createCategory(appId, userId, "奖金", "income", "bonus", "#FDCB6E", 2),
                createCategory(appId, userId, "投资", "income", "investment", "#74B9FF", 3),
                createCategory(appId, userId, "其他", "income", "other_income", "#636E72", 4)
        );
        categoryRepository.saveAll(defaults);
    }

    private Category createCategory(Long appId, Long userId, String name, String type, String icon, String color, int sortOrder) {
        Category c = new Category();
        c.setAppId(appId);
        c.setUserId(userId);
        c.setName(name);
        c.setType(type);
        c.setIcon(icon);
        c.setColor(color);
        c.setSortOrder(sortOrder);
        return c;
    }

    private void createDefaultAccount(Long appId, Long userId) {
        Account account = new Account();
        account.setAppId(appId);
        account.setUserId(userId);
        account.setName("现金");
        account.setType("cash");
        account.setBalance(BigDecimal.ZERO);
        account.setIcon("cash");
        account.setColor("#2D3436");
        account.setSortOrder(1);
        accountRepository.save(account);
    }

    private UserResponse toUserResponse(User user) {
        UserResponse resp = new UserResponse();
        resp.setId(user.getId());
        resp.setUsername(user.getUsername());
        resp.setNickname(user.getNickname());
        resp.setEmail(user.getEmail());
        resp.setAvatarUrl(user.getAvatarUrl());
        resp.setCreatedAt(user.getCreatedAt());
        return resp;
    }

}
