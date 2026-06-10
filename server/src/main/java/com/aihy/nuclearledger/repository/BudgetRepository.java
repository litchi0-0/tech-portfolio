package com.aihy.nuclearledger.repository;

import com.aihy.nuclearledger.entity.Budget;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BudgetRepository extends JpaRepository<Budget, Long> {

    List<Budget> findByAppIdAndUserIdOrderByMonthDesc(Long appId, Long userId);

    List<Budget> findByAppIdAndUserIdAndMonthOrderByMonthDesc(Long appId, Long userId, String month);

}
