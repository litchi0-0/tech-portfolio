# 水墨禅意极简重设计 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 tech-portfolio 前端全部 10 个页面重新设计为水墨禅意极简风格——黑白灰阶配色、赭砂点缀、全屏吸附布局、摄影集式大图展示。

**Architecture:** 公共页面完全移除 Ant Design，使用纯 CSS Modules + 自定义组件。管理后台保留 Ant Design 的 Table/Form 功能组件但通过 ConfigProvider theme 全面覆盖 token 灰阶化。所有 design token 通过 CSS Variables 定义。首页和部分页面使用 scroll-snap 全屏吸附布局。

**Tech Stack:** React 19, react-router-dom 7, ECharts 6 + echarts-for-react 3, CSS Modules, Noto Serif SC / Noto Sans SC (Google Fonts)

**Spec:** `docs/superpowers/specs/2026-06-11-ink-minimalist-redesign.md`

---

## File Structure Map

### New files to create
```
src/styles/tokens.css                              # CSS Variables (design tokens)
src/styles/theme-echarts.ts                        # ECharts ink theme config
src/components/SnapSection/SnapSection.tsx          # Full-screen snap container
src/components/SnapSection/SnapSection.module.css
src/components/SnapNav/SnapNav.tsx                  # Dot navigation
src/components/SnapNav/SnapNav.module.css
src/components/InkProgress/InkProgress.tsx          # Ink skill bar
src/components/InkProgress/InkProgress.module.css
src/components/InkTag/InkTag.tsx                    # Border-only tag
src/components/InkTag/InkTag.module.css
src/components/InkButton/InkButton.tsx              # Underline/fill button
src/components/InkButton/InkButton.module.css
src/components/InkInput/InkInput.tsx                # Underline input
src/components/InkInput/InkInput.module.css
```

### Files to rewrite completely
```
index.html                                         # Add Google Fonts
src/styles/global.css                               # Tokens import + reset + base
src/components/Layout/PublicLayout.tsx              # Minimal top bar
src/components/Layout/PublicLayout.module.css
src/components/Layout/AdminLayout.tsx               # Slim sidebar
src/components/Layout/AdminLayout.module.css
src/pages/Dashboard/index.tsx                       # 5-screen snap layout
src/pages/Dashboard/Dashboard.module.css
src/pages/TechShowcase/index.tsx                    # Radar + category snap
src/pages/TechShowcase/TechShowcase.module.css
src/pages/ProjectShowcase/index.tsx                 # Full-screen project gallery
src/pages/ProjectShowcase/ProjectShowcase.module.css
src/pages/BigScreen/index.tsx                       # Monochrome charts
src/pages/BigScreen/BigScreen.module.css
src/pages/TableDemo/index.tsx                       # Minimal table
src/pages/TableDemo/TableDemo.module.css
src/pages/ThreeJS/index.tsx                         # Ink-style 3D
src/pages/ThreeJS/ThreeJS.module.css
src/pages/Login/index.tsx                           # Zen login form
src/pages/Login/Login.module.css
src/pages/Admin/index.tsx                           # Admin dashboard
src/pages/Admin/Admin.module.css
src/pages/Admin/ProjectManage.tsx                    # Ink-themed admin
src/pages/Admin/TechStackManage.tsx
src/pages/Admin/ShowcaseManage.tsx
src/App.tsx                                         # Update imports, antd theme
```

### Files to keep unchanged
```
src/api/client.ts, src/api/portfolio.ts, src/api/admin.ts
src/types/index.ts
src/hooks/useAuth.ts, src/hooks/usePortfolio.ts
src/utils/constants.ts
vite.config.ts
```

---

## Task 1: Design Foundation

**Files:**
- Modify: `index.html`
- Create: `src/styles/tokens.css`
- Rewrite: `src/styles/global.css`
- Modify: `src/main.tsx`

- [ ] **Step 1: Update `index.html` to load Google Fonts and set Chinese lang**

```html
<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>墨 · 技术作品集</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+SC:wght@300;400;600&family=Noto+Sans+SC:wght@300;400;500&display=swap" rel="stylesheet" />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

- [ ] **Step 2: Create `src/styles/tokens.css`**

```css
:root {
  /* Ink tones */
  --ink-black: #0A0A0A;
  --ink-deep: #1A1A1A;
  --ink-heavy: #333333;
  --ink-light: #666666;
  --ink-faint: #999999;

  /* Paper tones */
  --paper-warm: #E8E4DE;
  --paper: #F5F3EF;
  --void: #FAFAF8;

  /* Accent */
  --accent: #A85A4A;

  /* Borders */
  --border-light: #E5E5E5;
  --border-dark: #222222;

  /* Typography */
  --font-serif: 'Noto Serif SC', Georgia, serif;
  --font-sans: 'Noto Sans SC', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;

  /* Sizing */
  --snap-height: 100vh;
  --content-padding: 80px 60px;
  --radius: 2px;

  /* Transitions */
  --transition-fast: 200ms ease;
  --transition-normal: 300ms ease;
}
```

- [ ] **Step 3: Rewrite `src/styles/global.css`**

```css
@import './tokens.css';

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
}

body {
  font-family: var(--font-sans);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: var(--void);
  color: var(--ink-black);
  font-size: 14px;
  line-height: 1.8;
}

a {
  color: inherit;
  text-decoration: none;
}

a:hover {
  color: var(--accent);
}

::selection {
  background: var(--accent);
  color: var(--void);
}

/* Scrollbar minimal style */
::-webkit-scrollbar {
  width: 4px;
}
::-webkit-scrollbar-track {
  background: transparent;
}
::-webkit-scrollbar-thumb {
  background: var(--ink-faint);
  border-radius: 2px;
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  html {
    scroll-behavior: auto;
  }
  * {
    transition-duration: 0ms !important;
    animation-duration: 0ms !important;
  }
}
```

- [ ] **Step 4: Verify in browser — `npm run dev`**

Expected: Page loads with Noto fonts, white background, no purple.

- [ ] **Step 5: Commit**

```bash
git add index.html src/styles/tokens.css src/styles/global.css src/main.tsx
git commit -m "feat: add design tokens, global styles, and Google Fonts for ink theme"
```

---

## Task 2: ECharts Ink Theme

**Files:**
- Create: `src/styles/theme-echarts.ts`

- [ ] **Step 1: Create `src/styles/theme-echarts.ts`**

```ts
import { registerTheme } from 'echarts/core';

const inkTheme = {
  color: ['#0A0A0A', '#333333', '#666666', '#999999', '#E5E5E5', '#A85A4A'],
  backgroundColor: 'transparent',
  textStyle: {
    color: '#666666',
    fontFamily: "'Noto Sans SC', system-ui, sans-serif",
  },
  title: {
    textStyle: { color: '#0A0A0A', fontFamily: "'Noto Serif SC', Georgia, serif", fontWeight: 300 },
    subtextStyle: { color: '#999999' },
  },
  line: {
    itemStyle: { borderWidth: 1 },
    lineStyle: { width: 1 },
    symbolSize: 4,
    symbol: 'circle',
    smooth: true,
  },
  bar: {
    itemStyle: {
      barBorderWidth: 0,
      barBorderColor: '#333333',
    },
  },
  pie: {
    itemStyle: {
      borderWidth: 1,
      borderColor: '#FAFAF8',
    },
  },
  radar: {
    name: { textStyle: { color: '#666666', fontSize: 11 } },
    splitLine: { lineStyle: { color: '#E5E5E5' } },
    splitArea: { show: false },
    axisLine: { lineStyle: { color: '#E5E5E5' } },
  },
  heatmap: {
    itemStyle: {
      borderWidth: 1,
      borderColor: '#FAFAF8',
    },
  },
  tooltip: {
    backgroundColor: '#0A0A0A',
    borderColor: '#333333',
    textStyle: { color: '#FAFAF8', fontSize: 12 },
  },
  legend: {
    textStyle: { color: '#666666' },
  },
  categoryAxis: {
    axisLine: { show: true, lineStyle: { color: '#E5E5E5' } },
    axisTick: { show: false },
    axisLabel: { color: '#999999', fontSize: 11 },
    splitLine: { show: false },
  },
  valueAxis: {
    axisLine: { show: false },
    axisTick: { show: false },
    axisLabel: { color: '#999999', fontSize: 11 },
    splitLine: { lineStyle: { color: '#F0F0F0', type: 'dashed' } },
  },
};

registerTheme('ink', inkTheme);

export default inkTheme;
```

- [ ] **Step 2: Commit**

```bash
git add src/styles/theme-echarts.ts
git commit -m "feat: add ECharts ink theme with monochrome palette"
```

---

## Task 3: Reusable Ink Components

**Files:**
- Create: `src/components/SnapSection/SnapSection.tsx` + `.module.css`
- Create: `src/components/SnapNav/SnapNav.tsx` + `.module.css`
- Create: `src/components/InkProgress/InkProgress.tsx` + `.module.css`
- Create: `src/components/InkTag/InkTag.tsx` + `.module.css`
- Create: `src/components/InkButton/InkButton.tsx` + `.module.css`
- Create: `src/components/InkInput/InkInput.tsx` + `.module.css`

- [ ] **Step 1: Create SnapSection**

`src/components/SnapSection/SnapSection.module.css`:
```css
.section {
  height: var(--snap-height);
  scroll-snap-align: start;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: var(--content-padding);
  position: relative;
  overflow: hidden;
}

.dark {
  background-color: var(--ink-black);
  color: var(--void);
}

.light {
  background-color: var(--void);
  color: var(--ink-black);
}
```

`src/components/SnapSection/SnapSection.tsx`:
```tsx
import React from 'react';
import styles from './SnapSection.module.css';

interface SnapSectionProps {
  variant?: 'dark' | 'light';
  className?: string;
  children: React.ReactNode;
}

const SnapSection: React.FC<SnapSectionProps> = ({ variant = 'light', className, children }) => (
  <section className={`${styles.section} ${styles[variant]} ${className || ''}`}>
    {children}
  </section>
);

export default SnapSection;
```

- [ ] **Step 2: Create SnapNav**

`src/components/SnapNav/SnapNav.module.css`:
```css
.nav {
  position: fixed;
  right: 24px;
  top: 50%;
  transform: translateY(-50%);
  display: flex;
  flex-direction: column;
  gap: 12px;
  z-index: 100;
}

.dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background-color: var(--ink-faint);
  border: none;
  padding: 0;
  cursor: pointer;
  transition: background-color var(--transition-fast);
}

.dot:hover {
  background-color: var(--ink-heavy);
}

.dotActive {
  background-color: var(--accent);
}

.dot:hover.dotActive {
  background-color: var(--accent);
}
```

`src/components/SnapNav/SnapNav.tsx`:
```tsx
import React, { useEffect, useRef, useState } from 'react';
import styles from './SnapNav.module.css';

interface SnapNavProps {
  containerRef: React.RefObject<HTMLElement | null>;
  count: number;
}

const SnapNav: React.FC<SnapNavProps> = ({ containerRef, count }) => {
  const [activeIndex, setActiveIndex] = useState(0);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const sections = container.querySelectorAll('section');
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const idx = Array.from(sections).indexOf(entry.target);
            if (idx >= 0) setActiveIndex(idx);
          }
        });
      },
      { root: container, threshold: 0.5 }
    );

    sections.forEach((s) => observer.observe(s));
    return () => observer.disconnect();
  }, [containerRef]);

  const handleClick = (index: number) => {
    const container = containerRef.current;
    if (!container) return;
    const sections = container.querySelectorAll('section');
    sections[index]?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <nav className={styles.nav}>
      {Array.from({ length: count }, (_, i) => (
        <button
          key={i}
          className={`${styles.dot} ${i === activeIndex ? styles.dotActive : ''}`}
          onClick={() => handleClick(i)}
          aria-label={`Section ${i + 1}`}
        />
      ))}
    </nav>
  );
};

export default SnapNav;
```

- [ ] **Step 3: Create InkProgress**

`src/components/InkProgress/InkProgress.module.css`:
```css
.row {
  margin-bottom: 16px;
}

.label {
  display: flex;
  justify-content: space-between;
  font-size: 11px;
  color: var(--ink-heavy);
  margin-bottom: 4px;
}

.value {
  color: var(--ink-faint);
}

.track {
  height: 2px;
  background-color: var(--border-light);
}

.fill {
  height: 100%;
  transition: width var(--transition-normal);
}
```

`src/components/InkProgress/InkProgress.tsx`:
```tsx
import React from 'react';
import styles from './InkProgress.module.css';

interface InkProgressProps {
  label: string;
  value: number; // 0-100
}

const getInkColor = (value: number): string => {
  if (value >= 85) return 'var(--ink-black)';
  if (value >= 65) return 'var(--ink-heavy)';
  return 'var(--ink-light)';
};

const InkProgress: React.FC<InkProgressProps> = ({ label, value }) => (
  <div className={styles.row}>
    <div className={styles.label}>
      <span>{label}</span>
      <span className={styles.value}>{value}%</span>
    </div>
    <div className={styles.track}>
      <div className={styles.fill} style={{ width: `${value}%`, backgroundColor: getInkColor(value) }} />
    </div>
  </div>
);

export default InkProgress;
```

- [ ] **Step 4: Create InkTag**

`src/components/InkTag/InkTag.module.css`:
```css
.tag {
  display: inline-block;
  font-size: 10px;
  padding: 2px 10px;
  border: 1px solid var(--border-light);
  color: var(--ink-heavy);
  border-radius: var(--radius);
  letter-spacing: 0.5px;
}

.dark {
  border-color: var(--border-dark);
  color: var(--ink-faint);
}

.accent {
  border-color: var(--accent);
  color: var(--accent);
}
```

`src/components/InkTag/InkTag.tsx`:
```tsx
import React from 'react';
import styles from './InkTag.module.css';

interface InkTagProps {
  variant?: 'default' | 'dark' | 'accent';
  children: React.ReactNode;
}

const InkTag: React.FC<InkTagProps> = ({ variant = 'default', children }) => (
  <span className={`${styles.tag} ${styles[variant]}`}>{children}</span>
);

export default InkTag;
```

- [ ] **Step 5: Create InkButton**

`src/components/InkButton/InkButton.module.css`:
```css
.button {
  display: inline-block;
  font-size: 11px;
  padding: 8px 24px;
  border: none;
  cursor: pointer;
  letter-spacing: 2px;
  transition: all var(--transition-fast);
  border-radius: var(--radius);
  font-family: var(--font-sans);
}

.fill {
  background-color: var(--ink-black);
  color: var(--void);
}

.fill:hover {
  background-color: var(--ink-heavy);
}

.ghost {
  background: transparent;
  border: 1px solid var(--border-light);
  color: var(--ink-heavy);
}

.ghost:hover {
  border-color: var(--accent);
  color: var(--accent);
}

.underline {
  background: none;
  border: none;
  color: var(--ink-light);
  padding: 4px 0;
  position: relative;
}

.underline::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 0;
  height: 1px;
  background-color: var(--accent);
  transition: width var(--transition-fast);
}

.underline:hover {
  color: var(--ink-black);
}

.underline:hover::after {
  width: 100%;
}
```

`src/components/InkButton/InkButton.tsx`:
```tsx
import React from 'react';
import styles from './InkButton.module.css';

interface InkButtonProps {
  variant?: 'fill' | 'ghost' | 'underline';
  onClick?: () => void;
  children: React.ReactNode;
  className?: string;
}

const InkButton: React.FC<InkButtonProps> = ({ variant = 'fill', onClick, children, className }) => (
  <button className={`${styles.button} ${styles[variant]} ${className || ''}`} onClick={onClick}>
    {children}
  </button>
);

export default InkButton;
```

- [ ] **Step 6: Create InkInput**

`src/components/InkInput/InkInput.module.css`:
```css
.wrapper {
  margin-bottom: 16px;
}

.label {
  font-size: 9px;
  color: var(--ink-faint);
  letter-spacing: 1px;
  margin-bottom: 4px;
  text-transform: uppercase;
}

.input {
  width: 100%;
  border: none;
  border-bottom: 1px solid var(--border-light);
  background: transparent;
  padding: 8px 0;
  font-size: 14px;
  color: var(--ink-black);
  font-family: var(--font-sans);
  outline: none;
  transition: border-color var(--transition-fast);
}

.input::placeholder {
  color: var(--ink-faint);
}

.input:focus {
  border-bottom-color: var(--ink-heavy);
}

.textarea {
  resize: vertical;
  min-height: 80px;
}
```

`src/components/InkInput/InkInput.tsx`:
```tsx
import React from 'react';
import styles from './InkInput.module.css';

interface InkInputProps {
  label?: string;
  placeholder?: string;
  value?: string;
  onChange?: (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => void;
  multiline?: boolean;
  type?: string;
}

const InkInput: React.FC<InkInputProps> = ({ label, placeholder, value, onChange, multiline, type }) => (
  <div className={styles.wrapper}>
    {label && <div className={styles.label}>{label}</div>}
    {multiline ? (
      <textarea className={`${styles.input} ${styles.textarea}`} placeholder={placeholder} value={value} onChange={onChange} />
    ) : (
      <input className={styles.input} type={type || 'text'} placeholder={placeholder} value={value} onChange={onChange} />
    )}
  </div>
);

export default InkInput;
```

- [ ] **Step 7: Verify all components compile — `npm run dev`**

Expected: No compilation errors.

- [ ] **Step 8: Commit**

```bash
git add src/components/SnapSection/ src/components/SnapNav/ src/components/InkProgress/ src/components/InkTag/ src/components/InkButton/ src/components/InkInput/
git commit -m "feat: add SnapSection, SnapNav, InkProgress, InkTag, InkButton, InkInput components"
```

---

## Task 4: PublicLayout + App Shell

**Files:**
- Rewrite: `src/components/Layout/PublicLayout.tsx`
- Create: `src/components/Layout/PublicLayout.module.css`
- Rewrite: `src/App.tsx`

- [ ] **Step 1: Create `src/components/Layout/PublicLayout.module.css`**

```css
.layout {
  min-height: 100vh;
}

.topBar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 32px;
  z-index: 50;
  background: transparent;
  transition: background-color var(--transition-normal);
}

.topBarScrolled {
  background-color: var(--void);
  border-bottom: 1px solid var(--border-light);
}

.logo {
  font-family: var(--font-serif);
  font-size: 18px;
  font-weight: 300;
  color: var(--ink-black);
  letter-spacing: 4px;
  cursor: pointer;
  text-decoration: none;
}

.nav {
  display: flex;
  gap: 24px;
}

.navLink {
  font-size: 11px;
  color: var(--ink-faint);
  letter-spacing: 1px;
  text-decoration: none;
  transition: color var(--transition-fast);
  position: relative;
}

.navLink:hover,
.navLinkActive {
  color: var(--ink-black);
}

.navLinkActive::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  right: 0;
  height: 1px;
  background-color: var(--accent);
}

.content {
  padding-top: 0;
}
```

- [ ] **Step 2: Rewrite `src/components/Layout/PublicLayout.tsx`**

```tsx
import React, { useState, useEffect } from 'react';
import { Link, Outlet, useLocation } from 'react-router-dom';
import styles from './PublicLayout.module.css';

const navItems = [
  { path: '/', label: '首页' },
  { path: '/tech', label: '技术栈' },
  { path: '/projects', label: '项目' },
  { path: '/bigscreen', label: '大屏' },
  { path: '/table', label: '表格' },
  { path: '/threejs', label: '三维' },
];

const PublicLayout: React.FC = () => {
  const location = useLocation();
  const isHome = location.pathname === '/';
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 10);
    window.addEventListener('scroll', onScroll);
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  return (
    <div className={styles.layout}>
      {!isHome && (
        <div className={`${styles.topBar} ${scrolled ? styles.topBarScrolled : ''}`}>
          <Link to="/" className={styles.logo}>墨</Link>
          <nav className={styles.nav}>
            {navItems.map((item) => (
              <Link
                key={item.path}
                to={item.path}
                className={`${styles.navLink} ${location.pathname === item.path ? styles.navLinkActive : ''}`}
              >
                {item.label}
              </Link>
            ))}
          </nav>
        </div>
      )}
      <div className={styles.content}>
        <Outlet />
      </div>
    </div>
  );
};

export default PublicLayout;
```

- [ ] **Step 3: Update `src/App.tsx` — keep antd ConfigProvider for admin, import echarts theme**

```tsx
import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ConfigProvider, theme as antdTheme } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import PublicLayout from './components/Layout/PublicLayout';
import AdminLayout from './components/Layout/AdminLayout';
import Dashboard from './pages/Dashboard';
import TechShowcase from './pages/TechShowcase';
import ProjectShowcase from './pages/ProjectShowcase';
import BigScreen from './pages/BigScreen';
import TableDemo from './pages/TableDemo';
import ThreeJS from './pages/ThreeJS';
import Login from './pages/Login';
import AdminDashboard from './pages/Admin';
import ProjectManage from './pages/Admin/ProjectManage';
import TechStackManage from './pages/Admin/TechStackManage';
import ShowcaseManage from './pages/Admin/ShowcaseManage';
import { useAuth } from './hooks/useAuth';
import './styles/global.css';
import './styles/theme-echarts';

const antdInkTheme = {
  token: {
    colorPrimary: '#0A0A0A',
    colorBgContainer: '#FAFAF8',
    colorBgLayout: '#FAFAF8',
    colorBorder: '#E5E5E5',
    colorText: '#0A0A0A',
    colorTextSecondary: '#666666',
    colorTextPlaceholder: '#999999',
    borderRadius: 2,
    fontFamily: "'Noto Sans SC', system-ui, sans-serif",
  },
};

const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();
  if (loading) return null;
  return isAuthenticated ? <>{children}</> : <Navigate to="/login" replace />;
};

const App: React.FC = () => {
  const { isAuthenticated, logout, user } = useAuth();

  return (
    <ConfigProvider locale={zhCN} theme={{ ...antdInkTheme, algorithm: antdTheme.defaultAlgorithm }}>
      <BrowserRouter>
        <Routes>
          <Route element={<PublicLayout />}>
            <Route path="/" element={<Dashboard />} />
            <Route path="/tech" element={<TechShowcase />} />
            <Route path="/projects" element={<ProjectShowcase />} />
            <Route path="/bigscreen" element={<BigScreen />} />
            <Route path="/table" element={<TableDemo />} />
            <Route path="/threejs" element={<ThreeJS />} />
          </Route>
          <Route path="/login" element={<Login />} />
          <Route path="/admin" element={
            <ProtectedRoute>
              <AdminLayout onLogout={logout} username={user?.nickname || user?.username} />
            </ProtectedRoute>
          }>
            <Route index element={<AdminDashboard />} />
            <Route path="projects" element={<ProjectManage />} />
            <Route path="tech-stacks" element={<TechStackManage />} />
            <Route path="showcases" element={<ShowcaseManage />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </ConfigProvider>
  );
};

export default App;
```

- [ ] **Step 4: Verify — `npm run dev`, check top bar appears on non-home pages**

- [ ] **Step 5: Commit**

```bash
git add src/components/Layout/PublicLayout.tsx src/components/Layout/PublicLayout.module.css src/App.tsx
git commit -m "feat: redesign PublicLayout with minimal ink nav bar, update App shell"
```

---

## Task 5: Dashboard (首页) — 5-Screen Snap Layout

**Files:**
- Rewrite: `src/pages/Dashboard/index.tsx`
- Create: `src/pages/Dashboard/Dashboard.module.css`

- [ ] **Step 1: Create `src/pages/Dashboard/Dashboard.module.css`**

```css
.snapContainer {
  height: 100vh;
  overflow-y: auto;
  scroll-snap-type: y mandatory;
}

/* Screen 1: Hero */
.hero {
  composes: section from '../../components/SnapSection/SnapSection.module.css';
  background: linear-gradient(135deg, #0a0a0a 0%, #1a1a1a 50%, #0a0a0a 100%);
  color: var(--void);
}

.heroLabel {
  font-size: 11px;
  letter-spacing: 4px;
  color: var(--ink-light);
  margin-bottom: 20px;
}

.heroTitle {
  font-family: var(--font-serif);
  font-size: 56px;
  font-weight: 300;
  letter-spacing: 8px;
  margin-bottom: 8px;
}

.heroDivider {
  width: 40px;
  height: 1px;
  background-color: var(--accent);
  margin: 16px auto;
}

.heroSub {
  font-family: var(--font-serif);
  font-size: 16px;
  font-weight: 300;
  color: var(--ink-faint);
  letter-spacing: 2px;
}

.scrollHint {
  position: absolute;
  bottom: 24px;
  left: 50%;
  transform: translateX(-50%);
  text-align: center;
}

.scrollLine {
  width: 1px;
  height: 24px;
  background: var(--ink-heavy);
  margin: 0 auto 6px;
}

.scrollText {
  font-size: 9px;
  color: var(--ink-heavy);
  letter-spacing: 2px;
}

/* Screen 2: Stats */
.stats {
  composes: section from '../../components/SnapSection/SnapSection.module.css';
}

.statsLabel {
  font-size: 11px;
  letter-spacing: 3px;
  color: var(--ink-faint);
  margin-bottom: 32px;
}

.statsRow {
  display: flex;
  gap: 80px;
  align-items: flex-end;
}

.statItem {
  text-align: center;
}

.statNumber {
  font-family: var(--font-serif);
  font-size: 64px;
  font-weight: 300;
  color: var(--ink-black);
  line-height: 1;
}

.statDivider {
  width: 20px;
  height: 1px;
  background-color: var(--accent);
  margin: 12px auto;
}

.statLabel {
  font-size: 12px;
  color: var(--ink-light);
  letter-spacing: 1px;
}

/* Screen 3: Projects */
.projects {
  composes: section from '../../components/SnapSection/SnapSection.module.css';
  background-color: var(--ink-black);
  color: var(--void);
  padding: 40px 60px;
}

.projectsInner {
  width: 100%;
  height: 100%;
  display: flex;
  gap: 16px;
  flex: 1;
}

.projectImage {
  flex: 2;
  background: linear-gradient(135deg, #1a1a1a, #2a2a2a);
  border-radius: var(--radius);
  position: relative;
  display: flex;
  align-items: flex-end;
  padding: 24px;
  min-height: 300px;
  overflow: hidden;
}

.projectImage img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.projectImageOverlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(to top, rgba(10,10,10,0.8) 0%, transparent 50%);
}

.projectNumber {
  position: absolute;
  top: 20px;
  left: 20px;
  font-family: var(--font-serif);
  font-size: 48px;
  color: rgba(255,255,255,0.1);
  font-weight: 300;
  z-index: 1;
}

.projectInfo {
  position: relative;
  z-index: 1;
}

.projectTitle {
  font-family: var(--font-serif);
  font-size: 20px;
  margin-bottom: 4px;
}

.projectDesc {
  font-size: 11px;
  color: var(--ink-light);
  max-width: 300px;
}

.projectTags {
  display: flex;
  gap: 6px;
  margin-top: 8px;
  flex-wrap: wrap;
}

.projectMeta {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
  justify-content: flex-end;
}

.projectNav {
  display: flex;
  justify-content: space-between;
  font-size: 10px;
  color: var(--ink-heavy);
  letter-spacing: 1px;
  margin-top: 12px;
}

.projectNavLink {
  cursor: pointer;
  transition: color var(--transition-fast);
}

.projectNavLink:hover {
  color: var(--void);
}

.projectNavCount {
  color: var(--ink-faint);
}

/* Screen 4: Tech Stack */
.techStack {
  composes: section from '../../components/SnapSection/SnapSection.module.css';
  flex-direction: row;
  padding: 80px 60px;
}

.techLeft {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.techLabel {
  font-size: 11px;
  letter-spacing: 3px;
  color: var(--ink-faint);
  margin-bottom: 20px;
}

.techTitle {
  font-family: var(--font-serif);
  font-size: 28px;
  font-weight: 300;
  color: var(--ink-black);
  margin-bottom: 16px;
}

.techRight {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Screen 5: Heatmap */
.heatmap {
  composes: section from '../../components/SnapSection/SnapSection.module.css';
}

.heatmapLabel {
  font-size: 11px;
  letter-spacing: 3px;
  color: var(--ink-faint);
  margin-bottom: 20px;
}

.heatmapLegend {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 9px;
  color: var(--ink-faint);
  margin-top: 12px;
}

.legendBlock {
  width: 8px;
  height: 8px;
  border-radius: 1px;
}
```

- [ ] **Step 2: Rewrite `src/pages/Dashboard/index.tsx`**

```tsx
import React, { useEffect, useState, useRef, useCallback } from 'react';
import ReactECharts from 'echarts-for-react';
import SnapNav from '../../components/SnapNav/SnapNav';
import InkProgress from '../../components/InkProgress/InkProgress';
import InkTag from '../../components/InkTag/InkTag';
import { portfolioApi } from '../../api/portfolio';
import type { Project, TechStack, Showcase } from '../../types';
import styles from './Dashboard.module.css';

const Dashboard: React.FC = () => {
  const [projects, setProjects] = useState<Project[]>([]);
  const [techStacks, setTechStacks] = useState<TechStack[]>([]);
  const [showcases, setShowcases] = useState<Showcase[]>([]);
  const [currentProject, setCurrentProject] = useState(0);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    Promise.all([
      portfolioApi.getProjects().catch(() => ({ data: [] })),
      portfolioApi.getTechStacks().catch(() => ({ data: [] })),
      portfolioApi.getShowcases().catch(() => ({ data: [] })),
    ]).then(([pRes, tRes, sRes]) => {
      setProjects((pRes as any).data || []);
      setTechStacks((tRes as any).data || []);
      setShowcases((sRes as any).data || []);
    });
  }, []);

  const prevProject = () => setCurrentProject((i) => Math.max(0, i - 1));
  const nextProject = () => setCurrentProject((i) => Math.min(projects.length - 1, i + 1));

  const handleKeyDown = useCallback((e: KeyboardEvent) => {
    if (e.key === 'ArrowLeft') prevProject();
    if (e.key === 'ArrowRight') nextProject();
  }, []);

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [handleKeyDown]);

  const project = projects[currentProject];

  // Radar chart option
  const radarOption = {
    radar: {
      indicator: techStacks.slice(0, 12).map((ts) => ({ name: ts.name, max: 100 })),
      splitLine: { lineStyle: { color: '#E5E5E5' } },
      splitArea: { show: false },
      axisLine: { lineStyle: { color: '#E5E5E5' } },
      name: { textStyle: { color: '#666', fontSize: 11 } },
    },
    series: [{
      type: 'radar',
      data: [{
        value: techStacks.slice(0, 12).map((ts) => ts.proficiency),
        areaStyle: { color: 'rgba(10,10,10,0.06)' },
        lineStyle: { color: '#0A0A0A', width: 1 },
        itemStyle: { color: '#A85A4A' },
      }],
    }],
  };

  // Heatmap option
  const heatmapOption = {
    grid: { top: 10, bottom: 30, left: 40, right: 10 },
    xAxis: { type: 'category', show: false },
    yAxis: { type: 'category', data: ['日', '一', '二', '三', '四', '五', '六'], axisLabel: { fontSize: 10, color: '#999' } },
    visualMap: {
      min: 0, max: 8, show: false,
      inRange: { color: ['#FAFAF8', '#E5E5E5', '#999999', '#666666', '#333333', '#0A0A0A'] },
    },
    series: [{
      type: 'heatmap',
      data: (() => {
        const data: [number, number, number][] = [];
        const today = new Date();
        const start = new Date(today.getFullYear(), 0, 1);
        for (let i = 0; i < 365; i++) {
          const d = new Date(start);
          d.setDate(d.getDate() + i);
          if (d > today) break;
          data.push([Math.floor(i / 7), i % 7, Math.floor(Math.random() * 8)]);
        }
        return data;
      })(),
      itemStyle: { borderRadius: 1, borderWidth: 1, borderColor: '#FAFAF8' },
    }],
  };

  return (
    <div className={styles.snapContainer} ref={containerRef}>
      <SnapNav containerRef={containerRef} count={5} />

      {/* Screen 1: Hero */}
      <section className={styles.hero}>
        <div className={styles.heroLabel}>TECH PORTFOLIO · {new Date().getFullYear()}</div>
        <div className={styles.heroTitle}>墨</div>
        <div className={styles.heroDivider} />
        <div className={styles.heroSub}>技术 · 作品 · 履历</div>
        <div className={styles.scrollHint}>
          <div className={styles.scrollLine} />
          <div className={styles.scrollText}>SCROLL</div>
        </div>
      </section>

      {/* Screen 2: Stats */}
      <section className={styles.stats}>
        <div className={styles.statsLabel}>OVERVIEW</div>
        <div className={styles.statsRow}>
          <div className={styles.statItem}>
            <div className={styles.statNumber}>{projects.length}</div>
            <div className={styles.statDivider} />
            <div className={styles.statLabel}>项目</div>
          </div>
          <div className={styles.statItem}>
            <div className={styles.statNumber}>{techStacks.length}</div>
            <div className={styles.statDivider} />
            <div className={styles.statLabel}>技术栈</div>
          </div>
          <div className={styles.statItem}>
            <div className={styles.statNumber}>{showcases.length}</div>
            <div className={styles.statDivider} />
            <div className={styles.statLabel}>展示</div>
          </div>
        </div>
      </section>

      {/* Screen 3: Featured Project */}
      <section className={styles.projects}>
        <div style={{ width: '100%', flex: 1, display: 'flex', flexDirection: 'column' }}>
          <div className={styles.projectsInner}>
            <div className={styles.projectImage}>
              {project?.coverImage && <img src={project.coverImage} alt={project.title} />}
              <div className={styles.projectImageOverlay} />
              <div className={styles.projectNumber}>{String(currentProject + 1).padStart(2, '0')}</div>
              <div className={styles.projectInfo}>
                <div className={styles.projectTitle}>{project?.title || '暂无项目'}</div>
                <div className={styles.projectDesc}>{project?.description?.substring(0, 100) || ''}</div>
                <div className={styles.projectTags}>
                  {project?.techStack?.split(',').map((t) => (
                    <InkTag key={t} variant="dark">{t.trim()}</InkTag>
                  ))}
                </div>
              </div>
            </div>
          </div>
          <div className={styles.projectNav}>
            <span className={styles.projectNavLink} onClick={prevProject}>← PREV</span>
            <span className={styles.projectNavCount}>{currentProject + 1} / {projects.length}</span>
            <span className={styles.projectNavLink} onClick={nextProject}>NEXT →</span>
          </div>
        </div>
      </section>

      {/* Screen 4: Tech Stack */}
      <section className={styles.techStack}>
        <div className={styles.techLeft}>
          <div className={styles.techLabel}>TECH STACK</div>
          <div className={styles.techTitle}>技术栈</div>
          {techStacks.slice(0, 6).map((ts) => (
            <InkProgress key={ts.id} label={ts.name} value={ts.proficiency} />
          ))}
        </div>
        <div className={styles.techRight}>
          {techStacks.length > 0 && (
            <ReactECharts option={radarOption} theme="ink" style={{ width: '100%', height: 300 }} />
          )}
        </div>
      </section>

      {/* Screen 5: Heatmap */}
      <section className={styles.heatmap}>
        <div className={styles.heatmapLabel}>COMMITS</div>
        <ReactECharts option={heatmapOption} theme="ink" style={{ height: 160, width: '100%' }} />
        <div className={styles.heatmapLegend}>
          <span>少</span>
          {['#FAFAF8', '#E5E5E5', '#999999', '#666666', '#333333', '#0A0A0A'].map((c) => (
            <div key={c} className={styles.legendBlock} style={{ backgroundColor: c, border: c === '#FAFAF8' ? '1px solid #E5E5E5' : 'none' }} />
          ))}
          <span>多</span>
        </div>
      </section>
    </div>
  );
};

export default Dashboard;
```

- [ ] **Step 3: Verify — open `/`, see hero screen, scroll through 5 screens**

- [ ] **Step 4: Commit**

```bash
git add src/pages/Dashboard/
git commit -m "feat: redesign Dashboard with 5-screen snap layout, ink theme"
```

---

## Task 6: TechShowcase Page

**Files:**
- Rewrite: `src/pages/TechShowcase/index.tsx`
- Create: `src/pages/TechShowcase/TechShowcase.module.css`

- [ ] **Step 1: Create CSS module with styles for radar + category screens**

`src/pages/TechShowcase/TechShowcase.module.css`:
```css
.container {
  height: 100vh;
  overflow-y: auto;
  scroll-snap-type: y mandatory;
  padding-top: 48px;
}

.screen {
  height: 100vh;
  scroll-snap-align: start;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 80px 60px;
  position: relative;
}

.screenLight {
  background-color: var(--void);
}

.label {
  font-size: 11px;
  letter-spacing: 3px;
  color: var(--ink-faint);
  margin-bottom: 8px;
  text-align: center;
}

.title {
  font-family: var(--font-serif);
  font-size: 28px;
  font-weight: 300;
  color: var(--ink-black);
  text-align: center;
  margin-bottom: 24px;
}

.radarWrap {
  width: 100%;
  max-width: 400px;
  margin-bottom: 24px;
}

.categories {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
  justify-content: center;
}

.catBtn {
  font-size: 10px;
  padding: 4px 14px;
  border: 1px solid var(--border-light);
  background: transparent;
  color: var(--ink-heavy);
  cursor: pointer;
  border-radius: var(--radius);
  letter-spacing: 1px;
  transition: all var(--transition-fast);
  font-family: var(--font-sans);
}

.catBtn:hover, .catBtnActive {
  border-color: var(--accent);
  color: var(--accent);
}

.catLabel {
  font-size: 10px;
  letter-spacing: 1px;
  color: var(--ink-faint);
  margin-bottom: 16px;
}

.catTitle {
  font-family: var(--font-serif);
  font-size: 22px;
  font-weight: 300;
  margin-bottom: 24px;
}
```

- [ ] **Step 2: Rewrite `src/pages/TechShowcase/index.tsx`**

```tsx
import React, { useEffect, useState, useRef } from 'react';
import ReactECharts from 'echarts-for-react';
import SnapNav from '../../components/SnapNav/SnapNav';
import InkProgress from '../../components/InkProgress/InkProgress';
import { portfolioApi } from '../../api/portfolio';
import type { TechStack } from '../../types';
import styles from './TechShowcase.module.css';

const categoryLabels: Record<string, string> = {
  frontend: '前端 FRONTEND', backend: '后端 BACKEND', database: '数据库 DATABASE',
  devops: 'DevOps', other: '其他 OTHER',
};

const TechShowcase: React.FC = () => {
  const [techStacks, setTechStacks] = useState<TechStack[]>([]);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    portfolioApi.getTechStacks().then((res: any) => setTechStacks(res.data || [])).catch(() => {});
  }, []);

  const grouped = techStacks.reduce((acc, ts) => {
    const cat = ts.category || 'other';
    if (!acc[cat]) acc[cat] = [];
    acc[cat].push(ts);
    return acc;
  }, {} as Record<string, TechStack[]>);

  const categories = Object.keys(grouped);
  const screenCount = 1 + categories.length;

  const scrollToCategory = (cat: string) => {
    const idx = categories.indexOf(cat);
    if (idx < 0) return;
    const container = containerRef.current;
    if (!container) return;
    const sections = container.querySelectorAll('section');
    sections[idx + 1]?.scrollIntoView({ behavior: 'smooth' });
  };

  const radarOption = {
    radar: {
      indicator: techStacks.slice(0, 12).map((ts) => ({ name: ts.name, max: 100 })),
      splitLine: { lineStyle: { color: '#E5E5E5' } },
      splitArea: { show: false },
      axisLine: { lineStyle: { color: '#E5E5E5' } },
      name: { textStyle: { color: '#666', fontSize: 11 } },
    },
    series: [{
      type: 'radar',
      data: [{
        value: techStacks.slice(0, 12).map((ts) => ts.proficiency),
        areaStyle: { color: 'rgba(10,10,10,0.06)' },
        lineStyle: { color: '#0A0A0A', width: 1 },
        itemStyle: { color: '#A85A4A' },
      }],
    }],
  };

  return (
    <div className={styles.container} ref={containerRef}>
      <SnapNav containerRef={containerRef} count={screenCount} />

      {/* Screen 1: Radar overview */}
      <section className={`${styles.screen} ${styles.screenLight}`}>
        <div className={styles.label}>TECH SHOWCASE</div>
        <div className={styles.title}>技术图谱</div>
        <div className={styles.radarWrap}>
          <ReactECharts option={radarOption} theme="ink" style={{ height: 300 }} />
        </div>
        <div className={styles.categories}>
          {categories.map((cat) => (
            <button key={cat} className={styles.catBtn} onClick={() => scrollToCategory(cat)}>
              {categoryLabels[cat] || cat}
            </button>
          ))}
        </div>
      </section>

      {/* Category screens */}
      {categories.map((cat) => (
        <section key={cat} className={`${styles.screen} ${styles.screenLight}`}>
          <div className={styles.catLabel}>{categoryLabels[cat] || cat}</div>
          <div className={styles.catTitle}>{(categoryLabels[cat] || cat).split(' ')[0]}</div>
          <div style={{ width: '100%', maxWidth: 600 }}>
            {grouped[cat].map((ts) => (
              <InkProgress key={ts.id} label={ts.name} value={ts.proficiency} />
            ))}
          </div>
        </section>
      ))}
    </div>
  );
};

export default TechShowcase;
```

- [ ] **Step 3: Verify — `/tech` shows radar + category snap screens**

- [ ] **Step 4: Commit**

```bash
git add src/pages/TechShowcase/
git commit -m "feat: redesign TechShowcase with snap layout and ink radar chart"
```

---

## Task 7: ProjectShowcase Page

**Files:**
- Rewrite: `src/pages/ProjectShowcase/index.tsx`
- Create: `src/pages/ProjectShowcase/ProjectShowcase.module.css`

Follow same pattern as Task 6: dark background full-screen per project, filter pills at top, left image + right meta panel, prev/next navigation with keyboard support.

Key differences from Dashboard screen 3:
- Has filter bar at top (category pills with accent border on active)
- Takes full page, not a snap section within dashboard
- Shows Demo/Code links in meta panel

- [ ] **Step 1: Create CSS and rewrite component (same pattern as Task 6)**

Implementation: Full-screen dark (`--ink-black`) layout. Top bar with title "作品集" + filter pills. Each project fills viewport: left 2/3 image area, right 1/3 meta panel with tech tags + links. Bottom prev/next nav.

- [ ] **Step 2: Verify — `/projects` shows full-screen project gallery**

- [ ] **Step 3: Commit**

```bash
git add src/pages/ProjectShowcase/
git commit -m "feat: redesign ProjectShowcase with full-screen gallery layout"
```

---

## Task 8: BigScreen, TableDemo, ThreeJS Pages

**Files:**
- Rewrite: `src/pages/BigScreen/index.tsx` + `.module.css`
- Rewrite: `src/pages/TableDemo/index.tsx` + `.module.css`
- Rewrite: `src/pages/ThreeJS/index.tsx` + `.module.css`

### BigScreen
- Dark background `--ink-black`, 2×2 grid
- All chart colors: `['#0A0A0A', '#333', '#666', '#999', '#E5E5E5', '#A85A4A']`
- Use `theme="ink"` on all ReactECharts
- Gauge → replace with large serif number + accent divider (no gauge ring)
- Border: 1px `--ink-deep` on each chart container

### TableDemo
- Light background, custom minimal `<table>` (no antd Table)
- 1px `--border-light` rows, no zebra striping
- Status: `<InkTag>` with variant based on status
- Search: `<InkInput>` underline style
- Pagination: simple prev/next + page number

### ThreeJS
- Dark background, scatter3D with grayscale palette
- Remove CSS 3D transform demo (not in spec)
- Use `theme="ink"` on ReactECharts

- [ ] **Step 1: Rewrite all three pages with their CSS modules**

- [ ] **Step 2: Verify each page loads correctly**

- [ ] **Step 3: Commit**

```bash
git add src/pages/BigScreen/ src/pages/TableDemo/ src/pages/ThreeJS/
git commit -m "feat: redesign BigScreen, TableDemo, ThreeJS with ink theme"
```

---

## Task 9: Login Page

**Files:**
- Rewrite: `src/pages/Login/index.tsx`
- Create: `src/pages/Login/Login.module.css`

- [ ] **Step 1: Create ink-themed login page**

Design: `--void` background, centered 280px form. Serif "墨" logo (36px) + accent divider + "MANAGEMENT" label. `<InkInput>` for username/password. `<InkButton variant="fill">` for submit. Bottom-right radial gradient decoration.

- [ ] **Step 2: Verify — `/login` shows zen login form**

- [ ] **Step 3: Commit**

```bash
git add src/pages/Login/
git commit -m "feat: redesign Login page with ink zen style"
```

---

## Task 10: Admin Layout + Dashboard

**Files:**
- Rewrite: `src/components/Layout/AdminLayout.tsx`
- Create: `src/components/Layout/AdminLayout.module.css`
- Rewrite: `src/pages/Admin/index.tsx`
- Create: `src/pages/Admin/Admin.module.css`

### AdminLayout
- Slim sidebar: 56px wide, `--ink-black` background
- Serif "墨" logo at top
- Vertical text nav items, accent left border + accent color on active
- Bottom: grayscale user avatar circle
- Top bar: `--void` background, 1px bottom border, breadcrumb left + user dropdown right
- Content: `--void` background, minimal padding

### Admin Dashboard
- Keep antd Statistic cards but styled through the theme override
- 3 stat cards with 1px `--border-light` border

- [ ] **Step 1: Rewrite AdminLayout and Admin Dashboard**

- [ ] **Step 2: Verify — `/admin` shows slim sidebar + ink-themed stats**

- [ ] **Step 3: Commit**

```bash
git add src/components/Layout/AdminLayout.tsx src/components/Layout/AdminLayout.module.css src/pages/Admin/
git commit -m "feat: redesign AdminLayout with slim ink sidebar and admin dashboard"
```

---

## Task 11: Admin CRUD Pages

**Files:**
- Rewrite: `src/pages/Admin/ProjectManage.tsx`
- Rewrite: `src/pages/Admin/TechStackManage.tsx`
- Rewrite: `src/pages/Admin/ShowcaseManage.tsx`

These pages keep antd Table + Form + Modal for their functionality but benefit from the antd theme override in App.tsx. Visual changes:
- The theme override already handles colors/borders/radius via ConfigProvider
- Add custom CSS for action buttons (text-link style) and status tags (border-only)
- Minimal changes needed — the antd theme token handles most of the visual transformation

- [ ] **Step 1: Apply minimal visual tweaks to admin pages (status tags, action buttons)**

- [ ] **Step 2: Verify CRUD operations still work**

- [ ] **Step 3: Commit**

```bash
git add src/pages/Admin/
git commit -m "feat: apply ink styling to admin CRUD pages"
```

---

## Task 12: Cleanup

**Files:**
- Delete: `src/components/CommitGraph/.gitkeep`
- Delete: `src/components/ProjectCard/.gitkeep`
- Delete: `src/components/TechStackChart/.gitkeep`
- Verify no orphaned antd imports in public pages

- [ ] **Step 1: Remove empty placeholder directories and unused gitkeep files**

- [ ] **Step 2: Search all public page files for any remaining antd imports and remove them**

```bash
grep -rn "from 'antd'" src/pages/Dashboard/ src/pages/TechShowcase/ src/pages/ProjectShowcase/ src/pages/BigScreen/ src/pages/TableDemo/ src/pages/ThreeJS/ src/pages/Login/
```

Expected: No results (only admin pages should import antd).

- [ ] **Step 3: Final verification — visit every route, check for console errors**

Routes to verify: `/`, `/tech`, `/projects`, `/bigscreen`, `/table`, `/threejs`, `/login`

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: cleanup empty directories and remove unused antd imports from public pages"
```

---

## Verification Checklist

1. `npm run dev` — no compilation errors
2. Visit `/` — 5-screen snap layout with hero, stats, projects, tech, heatmap
3. Visit `/tech` — radar chart + category snap screens
4. Visit `/projects` — full-screen project gallery with prev/next
5. Visit `/bigscreen` — 2×2 monochrome charts on dark background
6. Visit `/table` — minimal table, no antd styling visible
7. Visit `/threejs` — dark 3D scatter with grayscale dots
8. Visit `/login` — zen form with serif logo, underline inputs
9. Visit `/admin` (after login) — slim sidebar, ink-themed stats
10. Console: no errors, no warnings about missing imports
11. All fonts loading: Noto Serif SC and Noto Sans SC visible in Network tab
