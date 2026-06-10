# NuclearLedger API 接口文档

> 后端地址：`http://你的电脑IP:8080`
> 所有接口前缀：`/api`
> 时间格式：`yyyy-MM-dd HH:mm:ss`

---

## 一、通用说明

### 请求头

| 请求头 | 必填 | 说明 |
|--------|------|------|
| `Content-Type` | 是 | `application/json` |
| `X-App-Key` | 注册/登录必填 | 你的 App 密钥，目前可用的 key 见下表 |
| `Authorization` | 除注册/登录/ping 外必填 | `Bearer {token}` |

### 可用 App Key

| App Key | 说明 |
|---------|------|
| `nl_flutter_2026` | Flutter 移动端 |
| `nl_web_2026` | Web 端 |

> 如需新增 App，在数据库 `apps` 表中插入新行即可。

### 统一返回格式

**成功：**
```json
{
  "code": 200,
  "message": "success",
  "data": ...
}
```

**失败：**
```json
{
  "code": 400,
  "message": "错误原因",
  "data": null
}
```

---

## 二、接口列表

### 1. 测试后端连通性

```
GET /api/ping
```

不需要任何请求头。

**返回：**
```json
{
  "code": 200,
  "message": "success",
  "data": "server ok"
}
```

---

### 2. 注册

```
POST /api/auth/register
```

**请求头：**
```
Content-Type: application/json
X-App-Key: nl_flutter_2026
```

**请求体：**
```json
{
  "username": "test",
  "password": "123456",
  "nickname": "昵称"
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | String | 是 | 用户名 |
| password | String | 是 | 密码，最少6位 |
| nickname | String | 否 | 昵称，不填默认等于username |

**返回：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "username": "test",
    "nickname": "test",
    "email": null,
    "avatarUrl": null,
    "createdAt": "2026-06-03 14:30:00"
  }
}
```

> 注册成功后自动创建 12 个默认分类 + 1 个默认账户（现金）。

---

### 3. 登录

```
POST /api/auth/login
```

**请求头：**
```
Content-Type: application/json
X-App-Key: nl_flutter_2026
```

**请求体：**
```json
{
  "username": "test",
  "password": "123456"
}
```

**返回：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzM4NCJ9...",
    "tokenType": "Bearer",
    "user": {
      "id": 1,
      "username": "test",
      "nickname": "test",
      "email": null,
      "avatarUrl": null,
      "createdAt": "2026-06-03 14:30:00"
    }
  }
}
```

> 登录成功后保存 `token`，后续请求携带 `Authorization: Bearer {token}`。
> Token 有效期 7 天。

---

### 4. 获取当前用户信息

```
GET /api/user/me
```

**请求头：**
```
Authorization: Bearer {token}
```

**返回：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "username": "test",
    "nickname": "test",
    "email": null,
    "avatarUrl": null,
    "createdAt": "2026-06-03 14:30:00"
  }
}
```

---

### 5. 新增记账记录

```
POST /api/transactions
```

**请求头：**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**请求体：**
```json
{
  "accountId": 1,
  "categoryId": 1,
  "amount": 25.50,
  "type": "expense",
  "note": "午餐",
  "transactionDate": "2026-06-03 14:30:00"
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| accountId | Long | 是 | 账户ID |
| categoryId | Long | 是 | 分类ID |
| amount | BigDecimal | 是 | 金额，必须 > 0 |
| type | String | 是 | `"expense"` 或 `"income"` |
| note | String | 否 | 备注 |
| transactionDate | String | 是 | 记账时间，格式 `yyyy-MM-dd HH:mm:ss` |

**返回：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "accountId": 1,
    "categoryId": 1,
    "categoryName": "餐饮",
    "accountName": "现金",
    "amount": 25.50,
    "type": "expense",
    "note": "午餐",
    "transactionDate": "2026-06-03 14:30:00",
    "createdAt": "2026-06-03 14:31:00",
    "updatedAt": "2026-06-03 14:31:00"
  }
}
```

---

### 6. 查询记账列表

```
GET /api/transactions
```

**请求头：**
```
Authorization: Bearer {token}
```

**查询参数（全部可选）：**

| 参数 | 类型 | 说明 |
|------|------|------|
| type | String | `"expense"` 或 `"income"` |
| categoryId | Long | 按分类筛选 |
| accountId | Long | 按账户筛选 |
| startDate | String | 开始时间，如 `2026-06-01 00:00:00` |
| endDate | String | 结束时间，如 `2026-06-30 23:59:59` |

**示例：**
```
GET /api/transactions?type=expense&startDate=2026-06-01 00:00:00&endDate=2026-06-30 23:59:59
```

**返回：**
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "accountId": 1,
      "categoryId": 1,
      "categoryName": "餐饮",
      "accountName": "现金",
      "amount": 25.50,
      "type": "expense",
      "note": "午餐",
      "transactionDate": "2026-06-03 14:30:00",
      "createdAt": "2026-06-03 14:31:00",
      "updatedAt": "2026-06-03 14:31:00"
    }
  ]
}
```

> 按 transactionDate 倒序排列。

---

### 7. 查询记账详情

```
GET /api/transactions/{id}
```

**请求头：**
```
Authorization: Bearer {token}
```

**返回：** 同新增接口的 data 结构。

---

### 8. 修改记账记录

```
PUT /api/transactions/{id}
```

**请求头：**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**请求体：** 同新增接口。

**返回：** 同新增接口的 data 结构。

> 修改时会自动处理账户余额：先回滚旧金额，再应用新金额。

---

### 9. 删除记账记录

```
DELETE /api/transactions/{id}
```

**请求头：**
```
Authorization: Bearer {token}
```

**返回：**
```json
{
  "code": 200,
  "message": "success",
  "data": true
}
```

> 删除时自动恢复账户余额。

---

### 10. 查询分类列表

```
GET /api/categories
```

**请求头：**
```
Authorization: Bearer {token}
```

**查询参数（可选）：**

| 参数 | 类型 | 说明 |
|------|------|------|
| type | String | `"expense"` 或 `"income"` |

**返回：**
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "name": "餐饮",
      "type": "expense",
      "icon": "food",
      "color": "#FF6B6B",
      "sortOrder": 1,
      "createdAt": "2026-06-03 14:30:00",
      "updatedAt": "2026-06-03 14:30:00"
    }
  ]
}
```

---

### 11. 新增分类

```
POST /api/categories
```

**请求头：**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**请求体：**
```json
{
  "name": "Coffee",
  "type": "expense",
  "icon": "coffee",
  "color": "#FFAA00",
  "sortOrder": 1
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | String | 是 | 分类名称 |
| type | String | 是 | `"expense"` 或 `"income"` |
| icon | String | 否 | 图标标识 |
| color | String | 否 | 颜色值，如 `#FF6B6B` |
| sortOrder | Integer | 否 | 排序 |

**返回：** 同分类列表中的单个对象。

---

### 12. 修改分类

```
PUT /api/categories/{id}
```

请求体同新增分类，所有字段均可选。

---

### 13. 删除分类

```
DELETE /api/categories/{id}
```

> 如果该分类已被账单使用，会返回错误，不允许删除。

---

### 14. 查询账户列表

```
GET /api/accounts
```

**请求头：**
```
Authorization: Bearer {token}
```

**返回：**
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "name": "现金",
      "type": "cash",
      "balance": 0.00,
      "icon": "cash",
      "color": "#2D3436",
      "sortOrder": 1,
      "createdAt": "2026-06-03 14:30:00",
      "updatedAt": "2026-06-03 14:30:00"
    }
  ]
}
```

---

### 15. 新增账户

```
POST /api/accounts
```

**请求体：**
```json
{
  "name": "招商银行",
  "type": "bank_card",
  "balance": 10000.00,
  "icon": "card",
  "color": "#3377FF",
  "sortOrder": 2
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | String | 是 | 账户名称 |
| type | String | 是 | 见下表 |
| balance | BigDecimal | 否 | 初始余额，默认 0 |
| icon | String | 否 | 图标 |
| color | String | 否 | 颜色 |
| sortOrder | Integer | 否 | 排序 |

**账户 type 可选值：**

| 值 | 说明 |
|----|------|
| `cash` | 现金 |
| `bank_card` | 银行卡 |
| `wechat` | 微信 |
| `alipay` | 支付宝 |
| `credit_card` | 信用卡 |
| `other` | 其他 |

---

### 16. 修改账户

```
PUT /api/accounts/{id}
```

请求体同新增账户，所有字段均可选。

---

### 17. 删除账户

```
DELETE /api/accounts/{id}
```

> 如果该账户已被账单使用，会返回错误，不允许删除。

---

### 18. 查询预算列表

```
GET /api/budgets
```

**查询参数（可选）：**

| 参数 | 类型 | 说明 |
|------|------|------|
| month | String | 月份，格式 `yyyy-MM`，如 `2026-06` |

**返回：**
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "categoryId": 1,
      "categoryName": "餐饮",
      "amount": 1000.00,
      "month": "2026-06",
      "createdAt": "2026-06-03 14:30:00",
      "updatedAt": "2026-06-03 14:30:00"
    }
  ]
}
```

> `categoryId` 为 null 时表示整月总预算。

---

### 19. 新增预算

```
POST /api/budgets
```

**请求体：**
```json
{
  "categoryId": 1,
  "amount": 1000.00,
  "month": "2026-06"
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| categoryId | Long | 否 | 分类ID，不填表示总预算 |
| amount | BigDecimal | 是 | 预算金额，必须 > 0 |
| month | String | 是 | 月份，格式 `yyyy-MM` |

---

### 20. 修改预算

```
PUT /api/budgets/{id}
```

请求体同新增预算，所有字段均可选。

---

### 21. 删除预算

```
DELETE /api/budgets/{id}
```

---

## 三、默认分类列表

用户注册成功后自动创建以下分类：

### 支出分类（expense）

| 分类 | icon | color |
|------|------|-------|
| 餐饮 | food | #FF6B6B |
| 交通 | transport | #4ECDC4 |
| 购物 | shopping | #FF9F43 |
| 娱乐 | entertainment | #A29BFE |
| 住房 | housing | #FD79A8 |
| 医疗 | medical | #00B894 |
| 教育 | education | #6C5CE7 |
| 其他 | other_expense | #636E72 |

### 收入分类（income）

| 分类 | icon | color |
|------|------|-------|
| 工资 | salary | #00B894 |
| 奖金 | bonus | #FDCB6E |
| 投资 | investment | #74B9FF |
| 其他 | other_income | #636E72 |

---

## 四、Flutter 调用示例

### Dio 封装示例

```dart
import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'http://你的电脑IP:8080/api';
  static const String appKey = 'nl_flutter_2026';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // 设置 token
  static void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // 注册
  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    String? nickname,
  }) async {
    final res = await _dio.post(
      '/auth/register',
      data: {'username': username, 'password': password, 'nickname': nickname},
      options: Options(headers: {'X-App-Key': appKey}),
    );
    return res.data;
  }

  // 登录
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
      options: Options(headers: {'X-App-Key': appKey}),
    );
    final data = res.data;
    if (data['code'] == 200) {
      setToken(data['data']['token']);
    }
    return data;
  }

  // 获取记账列表
  static Future<Map<String, dynamic>> getTransactions({
    String? type,
    int? categoryId,
    int? accountId,
    String? startDate,
    String? endDate,
  }) async {
    final res = await _dio.get('/transactions', queryParameters: {
      if (type != null) 'type': type,
      if (categoryId != null) 'categoryId': categoryId,
      if (accountId != null) 'accountId': accountId,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    return res.data;
  }

  // 新增记账
  static Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> data) async {
    final res = await _dio.post('/transactions', data: data);
    return res.data;
  }

  // 修改记账
  static Future<Map<String, dynamic>> updateTransaction(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/transactions/$id', data: data);
    return res.data;
  }

  // 删除记账
  static Future<Map<String, dynamic>> deleteTransaction(int id) async {
    final res = await _dio.delete('/transactions/$id');
    return res.data;
  }

  // 获取分类列表
  static Future<Map<String, dynamic>> getCategories({String? type}) async {
    final res = await _dio.get('/categories', queryParameters: {
      if (type != null) 'type': type,
    });
    return res.data;
  }

  // 获取账户列表
  static Future<Map<String, dynamic>> getAccounts() async {
    final res = await _dio.get('/accounts');
    return res.data;
  }

  // 获取预算列表
  static Future<Map<String, dynamic>> getBudgets({String? month}) async {
    final res = await _dio.get('/budgets', queryParameters: {
      if (month != null) 'month': month,
    });
    return res.data;
  }
}
```

### 使用示例

```dart
// 注册
final result = await ApiClient.register(
  username: 'test',
  password: '123456',
);
if (result['code'] == 200) {
  print('注册成功');
}

// 登录（自动保存 token）
final loginResult = await ApiClient.login(
  username: 'test',
  password: '123456',
);
print('用户: ${loginResult['data']['user']['nickname']}');

// 获取分类
final categories = await ApiClient.getCategories(type: 'expense');
final list = categories['data'] as List;
for (var c in list) {
  print('${c['name']} - ${c['icon']}');
}

// 新增记账
await ApiClient.createTransaction({
  'accountId': 1,
  'categoryId': 1,
  'amount': 25.50,
  'type': 'expense',
  'note': '午餐',
  'transactionDate': '2026-06-03 14:30:00',
});
```

---

## 五、后端地址说明

| 场景 | 地址 |
|------|------|
| 本机浏览器 | `http://localhost:8080` |
| Android 模拟器 | `http://10.0.2.2:8080` |
| iOS 模拟器 | `http://localhost:8080` |
| 真机（同一局域网） | `http://你的电脑局域网IP:8080` |
| Flutter Web | `http://localhost:8080` |

> 查看电脑局域网 IP：Windows 打开 CMD 输入 `ipconfig`，找到 IPv4 地址。

---

## 六、注意事项

1. **X-App-Key 只在注册和登录时需要**，其他接口通过 JWT 自动识别来源 App
2. **Token 有效期 7 天**，过期后需重新登录
3. **所有时间字段** 统一使用 `yyyy-MM-dd HH:mm:ss` 格式
4. **跨域已配置**，Flutter Web 可直接调用
5. **数据库密码** 修改位置：`src/main/resources/application.yml` 第 7 行
