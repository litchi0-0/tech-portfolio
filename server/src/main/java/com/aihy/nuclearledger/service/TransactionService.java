package com.aihy.nuclearledger.service;

import com.aihy.nuclearledger.common.AppContext;
import com.aihy.nuclearledger.common.BusinessException;
import com.aihy.nuclearledger.dto.transaction.TransactionCreateRequest;
import com.aihy.nuclearledger.dto.transaction.TransactionResponse;
import com.aihy.nuclearledger.dto.transaction.TransactionUpdateRequest;
import com.aihy.nuclearledger.entity.Account;
import com.aihy.nuclearledger.entity.Category;
import com.aihy.nuclearledger.entity.Transaction;
import com.aihy.nuclearledger.repository.*;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TransactionService {

    private final TransactionRepository transactionRepository;
    private final AccountRepository accountRepository;
    private final CategoryRepository categoryRepository;

    @Transactional
    public TransactionResponse create(Long userId, TransactionCreateRequest request) {
        Long appId = AppContext.getAppId();
        validateRequest(request);

        Account account = accountRepository.findById(request.getAccountId())
                .orElseThrow(() -> new BusinessException("账户不存在"));
        if (!account.getAppId().equals(appId) || !account.getUserId().equals(userId)) {
            throw new BusinessException("无权操作该账户");
        }

        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new BusinessException("分类不存在"));
        if (!category.getAppId().equals(appId) || !category.getUserId().equals(userId)) {
            throw new BusinessException("无权操作该分类");
        }
        if (!category.getType().equals(request.getType())) {
            throw new BusinessException("分类类型与记录类型不一致");
        }

        Transaction transaction = new Transaction();
        transaction.setAppId(appId);
        transaction.setUserId(userId);
        transaction.setAccountId(request.getAccountId());
        transaction.setCategoryId(request.getCategoryId());
        transaction.setAmount(request.getAmount());
        transaction.setType(request.getType());
        transaction.setNote(request.getNote());
        transaction.setTransactionDate(request.getTransactionDate());

        transaction = transactionRepository.save(transaction);

        updateAccountBalance(account, request.getAmount(), request.getType());

        return toResponse(transaction);
    }

    public List<TransactionResponse> list(Long userId, String type, Long categoryId,
                                           Long accountId, String startDate, String endDate) {
        Long appId = AppContext.getAppId();

        Specification<Transaction> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.equal(root.get("appId"), appId));
            predicates.add(cb.equal(root.get("userId"), userId));

            if (type != null && !type.isBlank()) {
                predicates.add(cb.equal(root.get("type"), type));
            }
            if (categoryId != null) {
                predicates.add(cb.equal(root.get("categoryId"), categoryId));
            }
            if (accountId != null) {
                predicates.add(cb.equal(root.get("accountId"), accountId));
            }
            if (startDate != null && !startDate.isBlank()) {
                LocalDateTime start = LocalDateTime.parse(startDate, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                predicates.add(cb.greaterThanOrEqualTo(root.get("transactionDate"), start));
            }
            if (endDate != null && !endDate.isBlank()) {
                LocalDateTime end = LocalDateTime.parse(endDate, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                predicates.add(cb.lessThanOrEqualTo(root.get("transactionDate"), end));
            }

            query.orderBy(cb.desc(root.get("transactionDate")));
            return cb.and(predicates.toArray(new Predicate[0]));
        };

        return transactionRepository.findAll(spec).stream()
                .map(this::toResponse)
                .toList();
    }

    public TransactionResponse getDetail(Long userId, Long id) {
        Long appId = AppContext.getAppId();
        Transaction t = findAndCheckOwner(appId, userId, id);
        return toResponse(t);
    }

    @Transactional
    public TransactionResponse update(Long userId, Long id, TransactionUpdateRequest request) {
        Long appId = AppContext.getAppId();
        validateUpdateRequest(request);

        Transaction existing = findAndCheckOwner(appId, userId, id);

        // rollback old amount from old account
        Account oldAccount = accountRepository.findById(existing.getAccountId())
                .orElseThrow(() -> new BusinessException("旧账户不存在"));
        rollbackAccountBalance(oldAccount, existing.getAmount(), existing.getType());

        // validate new account
        Account newAccount = accountRepository.findById(request.getAccountId())
                .orElseThrow(() -> new BusinessException("账户不存在"));
        if (!newAccount.getAppId().equals(appId) || !newAccount.getUserId().equals(userId)) {
            throw new BusinessException("无权操作该账户");
        }

        // validate new category
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new BusinessException("分类不存在"));
        if (!category.getAppId().equals(appId) || !category.getUserId().equals(userId)) {
            throw new BusinessException("无权操作该分类");
        }
        if (!category.getType().equals(request.getType())) {
            throw new BusinessException("分类类型与记录类型不一致");
        }

        // apply new amount to new account
        updateAccountBalance(newAccount, request.getAmount(), request.getType());

        // update transaction
        existing.setAccountId(request.getAccountId());
        existing.setCategoryId(request.getCategoryId());
        existing.setAmount(request.getAmount());
        existing.setType(request.getType());
        existing.setNote(request.getNote());
        existing.setTransactionDate(request.getTransactionDate());

        existing = transactionRepository.save(existing);
        return toResponse(existing);
    }

    @Transactional
    public boolean delete(Long userId, Long id) {
        Long appId = AppContext.getAppId();
        Transaction existing = findAndCheckOwner(appId, userId, id);

        // restore account balance
        Account account = accountRepository.findById(existing.getAccountId())
                .orElseThrow(() -> new BusinessException("账户不存在"));
        rollbackAccountBalance(account, existing.getAmount(), existing.getType());

        transactionRepository.delete(existing);
        return true;
    }

    private Transaction findAndCheckOwner(Long appId, Long userId, Long id) {
        Transaction t = transactionRepository.findById(id)
                .orElseThrow(() -> new BusinessException("记录不存在"));
        if (!t.getAppId().equals(appId) || !t.getUserId().equals(userId)) {
            throw new BusinessException("无权操作该记录");
        }
        return t;
    }

    private void validateRequest(TransactionCreateRequest request) {
        if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new BusinessException("amount必须大于0");
        }
        validateType(request.getType());
        if (request.getAccountId() == null) {
            throw new BusinessException("accountId不能为空");
        }
        if (request.getCategoryId() == null) {
            throw new BusinessException("categoryId不能为空");
        }
        if (request.getTransactionDate() == null) {
            throw new BusinessException("transactionDate不能为空");
        }
    }

    private void validateUpdateRequest(TransactionUpdateRequest request) {
        if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new BusinessException("amount必须大于0");
        }
        validateType(request.getType());
        if (request.getAccountId() == null) {
            throw new BusinessException("accountId不能为空");
        }
        if (request.getCategoryId() == null) {
            throw new BusinessException("categoryId不能为空");
        }
        if (request.getTransactionDate() == null) {
            throw new BusinessException("transactionDate不能为空");
        }
    }

    private void validateType(String type) {
        if (type == null || (!type.equals("expense") && !type.equals("income"))) {
            throw new BusinessException("type必须是expense或income");
        }
    }

    private void updateAccountBalance(Account account, BigDecimal amount, String type) {
        if ("expense".equals(type)) {
            account.setBalance(account.getBalance().subtract(amount));
        } else {
            account.setBalance(account.getBalance().add(amount));
        }
        accountRepository.save(account);
    }

    private void rollbackAccountBalance(Account account, BigDecimal amount, String type) {
        if ("expense".equals(type)) {
            account.setBalance(account.getBalance().add(amount));
        } else {
            account.setBalance(account.getBalance().subtract(amount));
        }
        accountRepository.save(account);
    }

    private TransactionResponse toResponse(Transaction t) {
        TransactionResponse resp = new TransactionResponse();
        resp.setId(t.getId());
        resp.setAccountId(t.getAccountId());
        resp.setCategoryId(t.getCategoryId());
        resp.setAmount(t.getAmount());
        resp.setType(t.getType());
        resp.setNote(t.getNote());
        resp.setTransactionDate(t.getTransactionDate());
        resp.setCreatedAt(t.getCreatedAt());
        resp.setUpdatedAt(t.getUpdatedAt());

        categoryRepository.findById(t.getCategoryId()).ifPresent(c -> resp.setCategoryName(c.getName()));
        accountRepository.findById(t.getAccountId()).ifPresent(a -> resp.setAccountName(a.getName()));

        return resp;
    }

}
