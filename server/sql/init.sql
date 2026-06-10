-- ============================================================
-- nuclearledger 建库建表 SQL（多应用隔离版）
-- 文件路径: sql/init.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS nuclearledger DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE nuclearledger;

-- 应用表：每个接入的 App 一条记录
CREATE TABLE IF NOT EXISTS apps (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL COMMENT '应用名称',
    app_key VARCHAR(64) NOT NULL UNIQUE COMMENT '应用密钥，客户端通过 X-App-Key 请求头传入',
    description VARCHAR(200) COMMENT '应用描述',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '1:启用 0:禁用',
    created_at DATETIME NOT NULL,
    INDEX idx_apps_app_key (app_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    app_id BIGINT NOT NULL COMMENT '所属应用',
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    nickname VARCHAR(50),
    email VARCHAR(100),
    avatar_url VARCHAR(255),
    status TINYINT NOT NULL DEFAULT 1 COMMENT '1:正常 0:禁用',
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    UNIQUE KEY uk_app_username (app_id, username),
    INDEX idx_users_app_id (app_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 分类表
CREATE TABLE IF NOT EXISTS categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    app_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    name VARCHAR(50) NOT NULL,
    type VARCHAR(20) NOT NULL COMMENT 'expense or income',
    icon VARCHAR(50),
    color VARCHAR(20),
    sort_order INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    INDEX idx_categories_app_id (app_id),
    INDEX idx_categories_user_id (user_id),
    INDEX idx_categories_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 账户表
CREATE TABLE IF NOT EXISTS accounts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    app_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    name VARCHAR(50) NOT NULL,
    type VARCHAR(30) NOT NULL COMMENT 'cash/bank_card/wechat/alipay/credit_card/other',
    balance DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    icon VARCHAR(50),
    color VARCHAR(20),
    sort_order INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    INDEX idx_accounts_app_id (app_id),
    INDEX idx_accounts_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 记账记录表
CREATE TABLE IF NOT EXISTS transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    app_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    account_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    type VARCHAR(20) NOT NULL COMMENT 'expense or income',
    note VARCHAR(255),
    transaction_date DATETIME NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    INDEX idx_transactions_app_id (app_id),
    INDEX idx_transactions_user_id (user_id),
    INDEX idx_transactions_account_id (account_id),
    INDEX idx_transactions_category_id (category_id),
    INDEX idx_transactions_date (transaction_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 预算表
CREATE TABLE IF NOT EXISTS budgets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    app_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    category_id BIGINT COMMENT 'NULL means total budget for month',
    amount DECIMAL(12,2) NOT NULL,
    month VARCHAR(7) NOT NULL COMMENT 'yyyy-MM',
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    INDEX idx_budgets_app_id (app_id),
    INDEX idx_budgets_user_id (user_id),
    INDEX idx_budgets_category_id (category_id),
    INDEX idx_budgets_month (month)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 插入默认应用（可按需修改 app_key）
-- ============================================================
INSERT INTO apps (name, app_key, description, status, created_at) VALUES
('NuclearLedger Flutter', 'nl_flutter_2026', 'Flutter 记账App', 1, NOW()),
('NuclearLedger Web', 'nl_web_2026', 'Web 端记账', 1, NOW());
