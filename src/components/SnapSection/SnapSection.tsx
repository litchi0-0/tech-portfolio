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
