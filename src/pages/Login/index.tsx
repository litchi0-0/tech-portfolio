import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import InkInput from '../../components/InkInput/InkInput';
import InkButton from '../../components/InkButton/InkButton';
import styles from './Login.module.css';

const Login: React.FC = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleLogin = async () => {
    if (loading) return;
    setError('');

    if (!username.trim() || !password.trim()) {
      setError('请输入用户名和密码');
      return;
    }

    setLoading(true);
    try {
      await login(username, password);
      navigate('/admin');
    } catch (err: any) {
      setError(err.message || '登录失败');
    } finally {
      setLoading(false);
    }
  };

  const onSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    handleLogin();
  };

  return (
    <div className={styles.page}>
      <form className={styles.form} onSubmit={onSubmit}>
        <div className={styles.logo}>墨</div>
        <div className={styles.divider} />
        <div className={styles.label}>MANAGEMENT</div>

        <div className={styles.fields}>
          <InkInput
            placeholder="用户名"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
          />
          <InkInput
            type="password"
            placeholder="密码"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>

        <div className={styles.buttonWrap}>
          <InkButton variant="fill" onClick={handleLogin}>
            {loading ? '· · ·' : '登 录'}
          </InkButton>
        </div>

        {error && <div className={styles.error}>{error}</div>}
      </form>

      <div className={styles.splash} />
    </div>
  );
};

export default Login;
