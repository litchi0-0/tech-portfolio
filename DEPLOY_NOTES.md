# NuclearLedger 前端部署问题记录

## 部署环境

- 项目：tech-portfolio（React 19 + TypeScript + Vite + Ant Design）
- 服务器：阿里云 ECS Ubuntu 22.04（114.55.67.239）
- Web 服务器：Nginx 1.18.0
- 部署方式：本地 `npm run build` → `scp` 上传 `dist/` → Nginx 托管静态文件

---

## 错误 1：TypeScript 编译失败

### 现象

```
npm run build (tsc -b && vite build) 报错：

src/App.tsx(43,11): error TS6133: 'isAuthenticated' is declared but its value is never read.
src/components/SnapNav/SnapNav.tsx(21,54): error TS2345: Argument of type 'Element' is not assignable to parameter of type 'HTMLElement'.
src/pages/Admin/ProjectManage.tsx(2,73): error TS6133: 'Upload' is declared but its value is never read.
src/pages/Admin/ProjectManage.tsx(3,54): error TS6133: 'UploadOutlined' is declared but its value is never read.
src/pages/ProjectShowcase/index.tsx(57,54): error TS2345: Argument of type 'Element' is not assignable to parameter of type 'HTMLElement'.
src/pages/ProjectShowcase/index.tsx(141,16): error TS2322: Type 'RefObject<HTMLElement | null>' is not assignable to type 'Ref<HTMLDivElement> | undefined'.
```

### 原因

1. **TS6133** - 导入了变量但未使用（`isAuthenticated`、`Upload`、`UploadOutlined`）
2. **TS2345** - `querySelectorAll()` 返回 `NodeListOf<Element>`，`indexOf()` 期望 `HTMLElement`，类型不兼容
3. **TS2322** - `useRef<HTMLElement>` 赋值给 `ref={div}` 时，`HTMLElement` 缺少 `align` 属性，与 `HTMLDivElement` 不兼容

### 解决

| 文件 | 修改内容 |
|---|---|
| `src/App.tsx:43` | `{ isAuthenticated, logout, user }` → `{ logout, user }`，移除未使用的 `isAuthenticated` |
| `src/pages/Admin/ProjectManage.tsx:2-3` | 移除未使用的 `Upload`、`UploadOutlined` 导入 |
| `src/components/SnapNav/SnapNav.tsx:5` | `RefObject<HTMLElement \| null>` → `RefObject<HTMLDivElement \| null>` |
| `src/components/SnapNav/SnapNav.tsx:21` | `Array.from(sections).indexOf(entry.target)` → `Array.from(sections as NodeListOf<HTMLElement>).indexOf(entry.target as HTMLElement)` |
| `src/pages/ProjectShowcase/index.tsx:23` | `useRef<HTMLElement>` → `useRef<HTMLDivElement>` |
| `src/pages/ProjectShowcase/index.tsx:57` | 同 SnapNav 的类型断言修复 |

---

## 错误 2：PowerShell 无法运行 bash 脚本

### 现象

```powershell
bash deploy.sh
# 报错：bash : 无法将"bash"项识别为 cmdlet、函数、脚本文件或可运行程序的名称
```

### 原因

Windows PowerShell 中默认没有 `bash` 命令，`.sh` 脚本无法直接运行。

### 解决

将部署脚本重写为 PowerShell 版本 `deploy.ps1`，用 `ssh`、`scp` 等 Windows OpenSSH 命令替代 bash 语法。

---

## 错误 3：HTTP 502 Bad Gateway

### 现象

浏览器访问 `http://114.55.67.239` 返回：

```
该网页无法正常运作
114.55.67.239 目前无法处理此请求。
HTTP ERROR 502
```

### 排查过程

1. SSH 登录服务器检查：
   - Nginx 配置 `/etc/nginx/conf.d/tech-portfolio.conf` — 正确
   - `/etc/nginx/sites-enabled/` — 为空，无默认站点冲突
   - 静态文件 `/var/www/tech-portfolio/` — 存在（assets、favicon.svg、icons.svg、index.html）
   - Nginx 错误日志 — 无异常
   - Nginx 进程 — 正常运行
2. 服务器本地测试 `curl -I http://localhost` 返回 **200 OK**，说明 Nginx 工作正常

### 原因

**阿里云 ECS 安全组未放行 80 端口**。服务器本地可以访问，但外部流量被安全组防火墙拦截。

### 解决

在阿里云控制台添加安全组入方向规则：

| 协议 | 端口 | 授权对象 |
|---|---|---|
| TCP | 80 | 0.0.0.0/0 |

操作路径：ECS 控制台 → 实例 → 安全组 → 入方向 → 手动添加

---

## 部署架构

```
浏览器
  ↓
阿里云安全组 (TCP:80 放行)
  ↓
Nginx (:80)
  ├── /            → /var/www/tech-portfolio/index.html (SPA)
  ├── /assets/*    → /var/www/tech-portfolio/assets/ (静态资源)
  ├── /api/*       → proxy_pass http://localhost:8080 (后端，待部署)
  └── /uploads/*   → proxy_pass http://localhost:8080 (文件上传，待部署)
```

## 一键部署命令

```powershell
cd D:\work\project\nuclearleger\tech-portfolio
.\deploy.ps1
```
