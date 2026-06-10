package com.aihy.nuclearledger.dto.category;

import lombok.Data;

@Data
public class CategoryUpdateRequest {

    private String name;
    private String type;
    private String icon;
    private String color;
    private Integer sortOrder;

}
