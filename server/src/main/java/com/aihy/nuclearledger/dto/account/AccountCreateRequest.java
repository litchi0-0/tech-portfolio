package com.aihy.nuclearledger.dto.account;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class AccountCreateRequest {

    private String name;
    private String type;
    private BigDecimal balance;
    private String icon;
    private String color;
    private Integer sortOrder;

}
