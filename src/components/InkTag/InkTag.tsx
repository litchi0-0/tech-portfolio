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
