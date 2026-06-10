import React from 'react';
import styles from './InkProgress.module.css';

interface InkProgressProps {
  label: string;
  value: number;
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
