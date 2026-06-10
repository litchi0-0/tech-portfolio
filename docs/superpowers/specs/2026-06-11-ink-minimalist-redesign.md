# 水墨禅意极简重设计

## 概述

将 tech-portfolio 前端全部 10 个页面进行视觉重设计，采用"禅意极简数字空间"风格：黑白为基底、赭砂点缀、摄影集式大图展示、全屏吸附式布局。

## 设计系统

### 配色 — "墨分五色"

| Token | 名称 | 色值 | 用途 |
|-------|------|------|------|
| ink-black | 墨黑 | `#0A0A0A` | 主文字、深色背景 |
| ink-deep | 浓墨 | `#1A1A1A` | 次要深色、卡片背景 |
| ink-heavy | 重墨 | `#333333` | 辅助文字、图表二级色 |
| ink-light | 淡墨 | `#666666` | 说明文字、图表三级色 |
| ink-faint | 清墨 | `#999999` | 标注、placeholder |
| paper-warm | 宣纸 | `#E8E4DE` | 温暖分隔区域 |
| paper | 素宣 | `#F5F3EF` | 浅色背景变体 |
| void | 留白 | `#FAFAF8` | 主背景色 |
| accent | 赭砂 | `#A85A4A` | 唯一点缀色 |

### 赭砂使用规则

**允许**：关键数字/统计值、导航当前态、链接悬停、印章式 logo、图表最高值高亮。
**禁止**：大面积背景、多色渐变、图标填充、单屏超过 3 处同时使用。

### 字体

| 角色 | 字体 | 备选 | 大小/粗细 |
|------|------|------|-----------|
| 标题（H1-H3） | Noto Serif SC | Georgia, serif | H1: 48-56px/300, H2: 28-32px/300, H3: 18-20px/400 |
| 正文 | Noto Sans SC | system-ui, sans-serif | 14-16px/400, line-height: 1.8 |
| 标注/标签 | Noto Sans SC | system-ui, sans-serif | 11-12px/400, letter-spacing: 1-2px |
| 英文标注 | -apple-system, sans-serif | — | 9-11px, uppercase, letter-spacing: 2-3px |

Google Fonts 加载：`Noto Serif SC:wght@300;400;600` + `Noto Sans SC:wght@300;400;500`

### 间距与圆角

- 全屏区块：`height: 100vh`，内容居中，`padding: 80px 60px`
- 区块间距：无（scroll-snap 吸附）
- 元素间距：8px 基数（8, 16, 24, 32, 48, 64, 80）
- 圆角：0-2px（接近直角，克制）
- 分割线：1px，颜色 `#E5E5E5`（浅色背景上）或 `#222`（深色背景上）

### 动效

- 滚动吸附：`scroll-snap-type: y mandatory`
- 页面切换：淡入淡出 300ms ease
- hover：下划线展开 200ms（链接）、透明度变化（图片）
- 尊重 `prefers-reduced-motion`

---

## 页面设计

### 全局结构

- 右侧固定圆点导航（首页 5 点，其他页面数量随内容变化），赭砂标记当前屏
- 非首页的公开页面：左上角"墨"字 logo 可点击返回首页，右上角横向文字导航（极简）
- 首页：无传统顶栏，通过圆点导航 + 底部菜单链接跳转
- 翻页提示：底部小箭头 + "SCROLL" 文字

### 1. 首页（Dashboard）— 5 屏

**Screen 1 · 主视觉**
- 背景：墨黑 `#0A0A0A`，微妙的径向渐变
- 中心：衬线"墨"字（56px）+ "TECH PORTFOLIO · 2026" 标注
- 赭砂 1px 分割线（40px 宽）分隔中英文
- 底部：scroll 提示（竖线 + "SCROLL"）
- 右侧：5 个圆点导航

**Screen 2 · 数据刻度**
- 背景：留白 `#FAFAF8`
- 三个大数字横排，间距 80px
- 每个数字下方：赭砂 1px 分割线（20px 宽）+ 分类名（12px）
- 数字字体：Noto Serif SC, 64px, weight 300

**Screen 3 · 精选项目**
- 背景：墨黑 `#0A0A0A`
- 左侧 2/3：高清项目封面图（全高），左上角大号序号（48px）
- 右下角叠加：项目名（衬线）+ 简介（1-2 行）+ 技术标签（1px 边框小标签）
- 底部：← PREV | 1/6 | NEXT →
- 左右箭头键盘支持翻页

**Screen 4 · 技术栈**
- 背景：留白 `#FAFAF8`
- 左半：竖向进度条列表（2px 高，墨色填充，按熟练度用浓淡墨区分）
- 右半：极简雷达图（灰阶同心圆 + 墨色数据多边形 + 赭砂高亮点）
- 标注："TECH STACK"

**Screen 5 · 提交热力图**
- 背景：留白 `#FAFAF8`
- 居中：52×7 灰阶方块网格，用墨色五级灰代替 GitHub 绿色
- 当天用赭砂标记
- 底部图例：少 → 五级灰 → 多

### 2. 技术栈展示（TechShowcase）— scroll-snap

- 首屏：全屏雷达图（灰阶同心圆 + 数据面）+ 分类标签按钮
- 点击分类 → snap 到对应分类详情屏
- 每个分类详情屏：留白底 + 该分类下所有技术栈的进度条列表
- 技术栈卡片：名称 + 2px 进度条 + 简短描述

### 3. 项目展示（ProjectShowcase）— scroll-snap

- 墨黑底
- 顶部：标题"作品集" + 筛选标签（全部/前端/全栈/后端），赭砂边框标记当前
- 每个项目占满一屏：左侧大图 + 右侧元信息面板（技术栈标签、Demo/Code 链接）
- 底部翻页导航

### 4. 大屏可视化（BigScreen）— 网格布局

- 背景：墨黑 `#0A0A0A`
- 2×2 图表网格，每个图表区域 1px `#1A1A1A` 边框
- 图表配色统一灰阶：`#0A0A0A / #333 / #666 / #999`
- 赭砂仅用于：柱状图最高值柱、代码质量核心评分数字
- 四个图表：技术栈使用频率（柱状）、年度提交趋势（折线）、项目类型分布（环形）、代码质量评分（数字+分割线）

### 5. 表格演示（TableDemo）

- 留白底
- 极简表格：1px `#E5E5E5` 分隔线，无斑马纹
- 表头：小号灰色字母，weight 400
- 状态列：1px 边框标签（"在职"黑边、"离职"灰边）
- 搜索框：下划线式，无传统 input 边框
- 分页器：简约页码 + 前后箭头

### 6. 三维展示（ThreeJS）

- 墨黑底
- 3D 散点图：灰阶圆点，赭砂标记最高技能点
- 自动旋转
- 底部标注："技能三维分布 · 自动旋转"

### 7. 登录页（Login）

- 留白底，居中 280px 宽表单区域
- 顶部：衬线"墨"字（36px）+ 赭砂分割线 + "MANAGEMENT" 标注
- 输入框：下划线式（底部 1px 边框），无传统边框
- 登录按钮：墨黑底 `#0A0A0A`，留白文字，直角
- 右下角：极淡水墨渲染装饰（CSS radial-gradient）

### 8-10. 管理后台（Admin）

**侧边栏**：
- 宽度 56px，墨黑底
- 衬线"墨"字 logo
- 文字导航（竖排），赭砂左边框 + 赭砂色标记当前项
- 底部：用户头像（灰阶圆形）

**顶栏**：
- 留白底，1px 底边框
- 左侧：当前页面包屑/标题
- 右侧：用户名下拉（返回前台、退出登录）

**内容区**：
- 统计卡片：1px `#EEE` 边框，衬线大号数字
- 数据表格：与 TableDemo 相同样式
- 状态标签：1px 边框标签
- 操作按钮：文字链接式（"编辑""删除"），悬停下划线
- 新建/编辑表单：右侧抽屉面板滑出，表单字段用下划线式输入框

---

## 技术方案

### UI 方案调整

- **公共页面**：完全移除 Ant Design，用纯 CSS + 自定义组件，保持对每个像素的控制
- **管理后台**：保留 Ant Design 的 Table（排序/筛选/分页）和 Form（校验）功能组件，但通过 ConfigProvider theme 全面覆盖 token，将配色/圆角/字体全部灰阶化、直角化，使其视觉上融入水墨系统

### CSS 架构

- 使用 CSS Variables 定义所有 design token
- 全局样式表 `global.css` 定义 token 和 reset
- 每个页面/组件一个 `.module.css` 文件
- 不再使用 inline style

### 字体加载

```html
<link href="https://fonts.googleapis.com/css2?family=Noto+Serif+SC:wght@300;400;600&family=Noto+Sans+SC:wght@300;400;500&display=swap" rel="stylesheet">
```

### ECharts 主题

注册自定义墨色主题：
```js
{
  color: ['#0A0A0A', '#333333', '#666666', '#999999', '#E5E5E5', '#A85A4A'],
  backgroundColor: 'transparent',
  textStyle: { color: '#666', fontFamily: 'Noto Sans SC' },
  // ... 完整主题配置
}
```

### Scroll Snap 实现

```css
.snap-container {
  height: 100vh;
  overflow-y: auto;
  scroll-snap-type: y mandatory;
}
.snap-section {
  height: 100vh;
  scroll-snap-align: start;
}
```

### 圆点导航

- 固定定位右侧，z-index 最高
- 点击跳转到对应 section
- Intersection Observer 监听当前可见 section 更新高亮

---

## 文件结构变更

```
src/
├── styles/
│   ├── tokens.css          # Design tokens (CSS variables)
│   ├── global.css          # Reset + base styles
│   └── theme-echarts.ts    # ECharts 墨色主题配置
├── components/
│   ├── SnapNav/            # 圆点导航组件
│   ├── SnapSection/        # 全屏区块容器组件
│   ├── InkProgress/        # 墨色进度条组件
│   ├── InkTag/             # 边框标签组件
│   ├── InkButton/          # 按钮组件（下划线/填充两种）
│   ├── InkInput/           # 下划线式输入框
│   ├── InkTable/           # 极简表格组件
│   ├── Layout/
│   │   ├── PublicLayout.tsx
│   │   └── AdminLayout.tsx
│   ├── ProjectCard/
│   ├── CommitGraph/
│   └── TechStackChart/
├── pages/                  # 保持现有页面结构，重写内容
├── ...
```

---

## 不做的事

- 不引入新的 UI 框架（不用 Tailwind、styled-components 等）
- 不引入真正的 Three.js 库（保持 ECharts 3D）
- 不做 SSR / 预渲染
- 不改 API 接口层和数据结构
- 不改后端
- 不做暗色/亮色主题切换（固定禅意风格）
