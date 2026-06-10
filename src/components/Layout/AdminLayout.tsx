import React, { useState } from 'react';
import { Outlet, useLocation, useNavigate } from 'react-router-dom';
import styles from './AdminLayout.module.css';

const navItems = [
  { path: '/admin', label: '概览' },
  { path: '/admin/projects', label: '项目' },
  { path: '/admin/tech-stacks', label: '技术栈' },
  { path: '/admin/showcases', label: '展示' },
];

interface AdminLayoutProps {
  onLogout: () => void;
  username?: string;
}

const AdminLayout: React.FC<AdminLayoutProps> = ({ onLogout, username }) => {
  const location = useLocation();
  const navigate = useNavigate();
  const [dropdownOpen, setDropdownOpen] = useState(false);

  const isActive = (path: string) => {
    if (path === '/admin') return location.pathname === '/admin';
    return location.pathname.startsWith(path);
  };

  return (
    <div className={styles.layout}>
      <div className={styles.sidebar}>
        <div className={styles.sidebarLogo}>墨</div>
        <div className={styles.sidebarDivider} />
        <div className={styles.sidebarNav}>
          {navItems.map((item) => (
            <div
              key={item.path}
              className={`${styles.sidebarItem} ${isActive(item.path) ? styles.sidebarItemActive : ''}`}
              onClick={() => navigate(item.path)}
            >
              {item.label}
            </div>
          ))}
        </div>
        <div className={styles.sidebarAvatar}>
          {(username || '管')[0]}
        </div>
      </div>

      <div className={styles.main}>
        <div className={styles.topBar}>
          <div className={styles.topBarTitle}>
            {navItems.find((i) => isActive(i.path))?.label?.toUpperCase() || 'DASHBOARD'}
          </div>
          <div className={styles.topBarRight} onClick={() => setDropdownOpen(!dropdownOpen)}>
            {username || '管理员'} ▾
            {dropdownOpen && (
              <div className={styles.dropdown}>
                <div className={styles.dropdownItem} onClick={() => navigate('/')}>返回前台</div>
                <div className={styles.dropdownItem} onClick={onLogout}>退出登录</div>
              </div>
            )}
          </div>
        </div>
        <div className={styles.content}>
          <Outlet />
        </div>
      </div>
    </div>
  );
};

export default AdminLayout;
