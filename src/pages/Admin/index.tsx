import React, { useEffect, useState } from 'react';
import { adminApi } from '../../api/admin';
import styles from './Admin.module.css';

const AdminDashboard: React.FC = () => {
  const [stats, setStats] = useState({ projects: 0, techStacks: 0, showcases: 0 });

  useEffect(() => {
    Promise.all([
      adminApi.getProjects(),
      adminApi.getTechStacks(),
      adminApi.getShowcases(),
    ]).then(([p, t, s]) => {
      setStats({
        projects: (p as any).data?.length || 0,
        techStacks: (t as any).data?.length || 0,
        showcases: (s as any).data?.length || 0,
      });
    }).catch(() => {});
  }, []);

  return (
    <div>
      <div className={styles.statsRow}>
        <div className={styles.statCard}>
          <div className={styles.statLabel}>项目总数</div>
          <div className={styles.statNumber}>{stats.projects}</div>
        </div>
        <div className={styles.statCard}>
          <div className={styles.statLabel}>技术栈总数</div>
          <div className={styles.statNumber}>{stats.techStacks}</div>
        </div>
        <div className={styles.statCard}>
          <div className={styles.statLabel}>展示项总数</div>
          <div className={styles.statNumber}>{stats.showcases}</div>
        </div>
      </div>
    </div>
  );
};

export default AdminDashboard;
