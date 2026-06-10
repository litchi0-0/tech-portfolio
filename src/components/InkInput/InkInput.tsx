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
