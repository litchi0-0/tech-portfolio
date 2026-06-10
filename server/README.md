# NuclearLedger 后端运行指南

## 一、环境要求

| 环境 | 版本 |
|------|------|
| Java (JDK) | 21 |
| Maven | 3.9+（项目自带 mvnw，无需单独安装） |
| MySQL | 8.0+ |
| IDEA | 2024+（推荐） |

## 二、首次运行步骤

### 1. 启动 MySQL

确认 MySQL 服务正在运行：

```bash
# Windows 检查
net start | findstr MySQL

# 如果没有启动，用管理员身份运行
net start MySQL95
```

### 2. 创建数据库和表

```bash
# 连接 MySQL（密码改成你自己的）
mysql -uroot -p你的密码 -h 127.0.0.1 --default-character-set=utf8mb4

# 在 MySQL 命令行中执行
source D:/work/project/nuclearleger/nuclearledger-server/sql/init.sql;
```

这会创建：
- `nuclearledger` 数据库
- `apps`、`users`、`categories`、`accounts`、`transactions`、`budgets` 6 张表
- 2 个默认应用（`nl_flutter_2026`、`nl_web_2026`）

### 3. 修改数据库密码

如果你的 MySQL 密码不是 `123456`，修改配置文件：

```
文件：src/main/resources/application.yml
位置：第 7 行
修改：password: 123456  →  password: 你的密码
```

### 4. IDEA 配置 JDK

1. **File → Project Structure → Project**
   - SDK 选 **JDK 21**
   - Language Level 选 **21**
2. **File → Project Structure → Modules**
   - Language Level 选 **21**

### 5. 导入 Maven 依赖

- IDEA 右侧 **Maven 面板** → 点 🔄 刷新按钮
- 等待依赖下载完成（首次可能需要几分钟）

### 6. 启动项目

**方式一：IDEA 启动（推荐）**
- 打开 `NuclearledgerServerApplication.java`
- 点击 main 方法旁边的 ▶ 绿色三角
- 或用 **Shift+F10** 运行

**方式二：命令行启动**
```bash
cd D:/work/project/nuclearleger/nuclearledger-server
./mvnw spring-boot:run
```

### 7. 验证启动成功

浏览器打开：
```
http://localhost:8080/api/ping
```

返回以下内容说明启动成功：
```json
{"code":200,"message":"success","data":"server ok"}
```

## 三、在线接口文档

启动后可以访问 Swagger 在线调试页面：

```
http://localhost:8080/swagger-ui/index.html
```

可以在线查看所有接口、调试请求。

## 四、接口测试顺序

```bash
# 1. 测试连通
curl http://localhost:8080/api/ping

# 2. 注册（需要 X-App-Key 头）
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -H "X-App-Key: nl_flutter_2026" \
  -d '{"username":"test","password":"123456"}'

# 3. 登录（返回 token）
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -H "X-App-Key: nl_flutter_2026" \
  -d '{"username":"test","password":"123456"}'

# 4. 复制返回的 token，后续请求携带
# 将下面的 YOUR_TOKEN 替换成登录返回的 token

# 5. 查询分类
curl http://localhost:8080/api/categories \
  -H "Authorization: Bearer YOUR_TOKEN"

# 6. 查询账户
curl http://localhost:8080/api/accounts \
  -H "Authorization: Bearer YOUR_TOKEN"

# 7. 新增记账
curl -X POST http://localhost:8080/api/transactions \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"accountId":1,"categoryId":1,"amount":25.50,"type":"expense","note":"lunch","transactionDate":"2026-06-03 14:30:00"}'

# 8. 查询记账列表
curl http://localhost:8080/api/transactions \
  -H "Authorization: Bearer YOUR_TOKEN"

# 9. 删除记账
curl -X DELETE http://localhost:8080/api/transactions/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 五、同步接口到 Apifox

### 方式一：URL 导入（推荐）

1. 确保后端已启动
2. 打开 Apifox → 项目 → **导入数据**
3. 格式选 **OpenAPI**
4. URL 填：
   ```
   http://localhost:8080/v3/api-docs
   ```
5. 确认导入

### 方式二：文件导入

1. 打开 Apifox → 项目 → **导入数据**
2. 格式选 **OpenAPI**
3. 选择文件：`openapi.json`（项目根目录下）
4. 确认导入

### 方式三：Apifox Helper 插件

1. IDEA 安装 **Apifox Helper** 插件
2. 确认 JDK 配置为 21（File → Project Structure → Project → SDK）
3. 确认 Maven 依赖已导入（右侧 Maven 面板无红色报错）
4. Build → Rebuild Project
5. 打开任意 Controller 文件 → 右键 → **Apifox Helper** → **Upload to Apifox**

> 如果插件提示 "No endpoints be found"：File → Invalidate Caches → Invalidate and Restart，然后重试。

## 六、项目配置说明

### application.yml

```yaml
server:
  port: 8080                    # 后端端口

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/nuclearledger?...   # 数据库地址
    username: root              # 数据库用户名
    password: 123456            # 数据库密码（改这里）
  jpa:
    hibernate:
      ddl-auto: update          # 自动更新表结构（不要改成 create，会清数据）

jwt:
  secret: nuclearledger_secret_key_please_change_it_later_2026   # JWT 密钥
  expiration: 604800000         # Token 有效期（毫秒），7天
```

### 可用 App Key

| App Key | 说明 |
|---------|------|
| `nl_flutter_2026` | Flutter 移动端 |
| `nl_web_2026` | Web 端 |

新增 App：
```sql
INSERT INTO apps (name, app_key, description, status, created_at)
VALUES ('新App名称', '新的app_key', '描述', 1, NOW());
```

## 七、前端连接地址

| 场景 | 后端地址 |
|------|----------|
| 本机浏览器 / Flutter Web | `http://localhost:8080` |
| Android 模拟器 | `http://10.0.2.2:8080` |
| iOS 模拟器 | `http://localhost:8080` |
| 真机（同一 WiFi） | `http://电脑局域网IP:8080` |

> 查看电脑 IP：CMD 输入 `ipconfig`，找到 IPv4 地址。

## 八、常见问题

### Q: 启动报错 "Communications link failure"
**A:** MySQL 没启动或密码不对。检查 MySQL 服务状态，确认 `application.yml` 中的密码正确。

### Q: 启动报错 "Access denied for user"
**A:** 数据库密码错误。修改 `application.yml` 第 7 行的 `password`。

### Q: 接口返回 401 Unauthorized
**A:** Token 过期或没带。重新登录获取新 token，请求头加 `Authorization: Bearer {token}`。

### Q: 注册/登录返回 "无效的 X-App-Key"
**A:** 请求头必须带 `X-App-Key: nl_flutter_2026`。

### Q: MySQL 连接报 "Lost connection"
**A:** 重启 MySQL 服务：`net stop MySQL95 && net start MySQL95`（管理员 CMD）。

### Q: 端口 8080 被占用
**A:** 修改 `application.yml` 中的 `port: 8080` 改成其他端口，比如 `8081`。
