import { useState, useEffect, useCallback } from 'react';
import axios from 'axios';
import type { LoginResponse } from '../types';
import { APP_KEY, API_BASE_URL } from '../utils/constants';

interface User {
  id: number;
  username: string;
  nickname: string;
}

export function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const savedToken = localStorage.getItem('portfolio_token');
    const savedUser = localStorage.getItem('portfolio_user');
    if (savedToken && savedUser) {
      setToken(savedToken);
      setUser(JSON.parse(savedUser));
    }
    setLoading(false);
  }, []);

  const login = useCallback(async (username: string, password: string) => {
    const response = await axios.post(`${API_BASE_URL}/auth/login`, {
      username,
      password,
      appKey: APP_KEY,
    });
    const data = response.data;
    if (data.code === 200) {
      const loginData: LoginResponse = data.data;
      localStorage.setItem('portfolio_token', loginData.token);
      localStorage.setItem('portfolio_user', JSON.stringify(loginData.user));
      setToken(loginData.token);
      setUser(loginData.user);
      return true;
    }
    throw new Error(data.message || '登录失败');
  }, []);

  const logout = useCallback(() => {
    localStorage.removeItem('portfolio_token');
    localStorage.removeItem('portfolio_user');
    setToken(null);
    setUser(null);
  }, []);

  const isAuthenticated = !!token;

  return { user, token, loading, login, logout, isAuthenticated };
}
