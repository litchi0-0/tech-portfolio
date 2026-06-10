package com.aihy.nuclearledger.dto.transaction;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class TransactionCreateRequest {

    private Long accountId;
    private Long categoryId;
    private BigDecimal amount;
    private String type;
    private String note;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime transactionDate;

}
