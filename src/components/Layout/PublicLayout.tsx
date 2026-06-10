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
