package com.aihy.nuclearledger.service;

import com.aihy.nuclearledger.common.AppContext;
import com.aihy.nuclearledger.common.BusinessException;
import com.aihy.nuclearledger.dto.account.AccountCreateRequest;
import com.aihy.nuclearledger.dto.account.AccountResponse;
import com.aihy.nuclearledger.dto.account.AccountUpdateRequest;
import com.aihy.nuclearledger.entity.Account;
import com.aihy.nuclearledger.repository.AccountRepository;
import com.aihy.nuclearledger.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AccountService {

    private final AccountRepository accountRepository;
    private final TransactionRepository transactionRepository;

    public List<AccountResponse> list(Long userId) {
        Long appId = AppContext.getAppId();
        return accountRepository.findByAppIdAndUserIdOrderBySortOrderAsc(appId, userId).stream()
                .map(this::toResponse)
                .toList();
    }

    public AccountResponse create(Long userId, AccountCreateRequest request) {
        Long appId = AppContext.getAppId();
        if (request.getName() == null || request.getName().isBlank()) {
            throw new BusinessException("账户名称不能为空");
        }
        validateAccountType(request.getType());

        Account account = new Account();
        account.setAppId(appId);
        account.setUserId(userId);
        account.setName(request.getName());
        account.setType(request.getType());
        account.setBalance(request.getBalance() != null ? request.getBalance() : BigDecimal.ZERO);
        account.setIcon(request.getIcon());
        account.setColor(request.getColor());
        account.setSortOrder(request.getSortOrder() != null ? request.getSortOrder() : 0);

        account = accountRepository.save(account);
        return toResponse(account);
    }

    public AccountResponse update(Long userId, Long id, AccountUpdateRequest request) {
        Long appId = AppContext.getAppId();
        Account account = findAndCheckOwner(appId, userId, id);

        if (request.getName() != null && !request.getName().isBlank()) {
            account.setName(request.getName());
        }
        if (request.getType() != null) {
            validateAccountType(request.getType());
            account.setType(request.getType());
        }
        if (request.getBalance() != null) {
            account.setBalance(request.getBalance());
        }
        if (request.getIcon() != null) {
            account.setIcon(request.getIcon());
        }
        if (request.getColor() != null) {
            account.setColor(request.getColor());
        }
        if (request.getSortOrder() != null) {
            account.setSortOrder(request.getSortOrder());
        }

        account = accountRepository.save(account);
        return toResponse(account);
    }

    public boolean delete(Long userId, Long id) {
        Long appId = AppContext.getAppId();
        Account account = findAndCheckOwner(appId, userId, id);

        boolean hasTransactions = transactionRepository.exists((root, query, cb) ->
                cb.and(
                        cb.equal(root.get("appId"), appId),
                        cb.equal(root.get("accountId"), id),
                        cb.equal(root.get("userId"), userId)
                )
        );
        if (hasTransactions) {
            throw new BusinessException("该账户已被账单使用，无法删除");
        }

        accountRepository.delete(account);
        return true;
    }

    private Account findAndCheckOwner(Long appId, Long userId, Long id) {
        Account a = accountRepository.findById(id)
                .orElseThrow(() -> new BusinessException("账户不存在"));
        if (!a.getAppId().equals(appId) || !a.getUserId().equals(userId)) {
            throw new BusinessException("无权操作该账户");
        }
        return a;
    }

    private void validateAccountType(String type) {
        if (type == null || type.isBlank()) {
            throw new BusinessException("账户类型不能为空");
        }
        List<String> validTypes = List.of("cash", "bank_card", "wechat", "alipay", "credit_card", "other");
        if (!validTypes.contains(type)) {
            throw new BusinessException("账户类型必须是: cash, bank_card, wechat, alipay, credit_card, other");
        }
    }

    private AccountResponse toResponse(Account a) {
        AccountResponse resp = new AccountResponse();
        resp.setId(a.getId());
        resp.setName(a.getName());
        resp.setType(a.getType());
        resp.setBalance(a.getBalance());
        resp.setIcon(a.getIcon());
        resp.setColor(a.getColor());
        resp.setSortOrder(a.getSortOrder());
        resp.setCreatedAt(a.getCreatedAt());
        resp.setUpdatedAt(a.getUpdatedAt());
        return resp;
    }

}
