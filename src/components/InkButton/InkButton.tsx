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
