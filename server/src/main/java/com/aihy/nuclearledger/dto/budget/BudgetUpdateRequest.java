package com.aihy.nuclearledger.dto.budget;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class BudgetUpdateRequest {

    private Long categoryId;
    private BigDecimal amount;
    private String month;

}
