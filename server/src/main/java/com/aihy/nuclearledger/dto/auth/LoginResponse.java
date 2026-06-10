package com.aihy.nuclearledger.dto.auth;

import com.aihy.nuclearledger.dto.user.UserResponse;
import lombok.Data;

@Data
public class LoginResponse {

    private String token;
    private String tokenType = "Bearer";
    private UserResponse user;

}
