import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ConfigProvider, theme as antdTheme } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import PublicLayout from './components/Layout/PublicLayout';
import AdminLayout from './components/Layout/AdminLayout';
import Dashboard from './pages/Dashboard';
import TechShowcase from './pages/TechShowcase';
import ProjectShowcase from './pages/ProjectShowcase';
import BigScreen from './pages/BigScreen';
import TableDemo from './pages/TableDemo';
import ThreeJS from './pages/ThreeJS';
import Login from './pages/Login';
import AdminDashboard from './pages/Admin';
import ProjectManage from './pages/Admin/ProjectManage';
import TechStackManage from './pages/Admin/TechStackManage';
import ShowcaseManage from './pages/Admin/ShowcaseManage';
import { useAuth } from './hooks/useAuth';
import './styles/global.css';
import './styles/theme-echarts';

const antdInkTheme = {
  token: {
    colorPrimary: '#0A0A0A',
    colorBgContainer: '#FAFAF8',
    colorBgLayout: '#FAFAF8',
    colorBorder: '#E5E5E5',
    colorText: '#0A0A0A',
    colorTextSecondary: '#666666',
    colorTextPlaceholder: '#999999',
    borderRadius: 2,
    fontFamily: "'Noto Sans SC', system-ui, sans-serif",
  },
};

const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();
  if (loading) return null;
  return isAuthenticated ? <>{children}</> : <Navigate to="/login" replace />;
};

const App: React.FC = () => {
  const { logout, user } = useAuth();

  return (
    <ConfigProvider locale={zhCN} theme={{ ...antdInkTheme, algorithm: antdTheme.defaultAlgorithm }}>
      <BrowserRouter>
        <Routes>
          <Route element={<PublicLayout />}>
            <Route path="/" element={<Dashboard />} />
            <Route path="/tech" element={<TechShowcase />} />
            <Route path="/projects" element={<ProjectShowcase />} />
            <Route path="/bigscreen" element={<BigScreen />} />
            <Route path="/table" element={<TableDemo />} />
            <Route path="/threejs" element={<ThreeJS />} />
          </Route>
          <Route path="/login" element={<Login />} />
          <Route path="/admin" element={
            <ProtectedRoute>
              <AdminLayout onLogout={logout} username={user?.nickname || user?.username} />
            </ProtectedRoute>
          }>
            <Route index element={<AdminDashboard />} />
            <Route path="projects" element={<ProjectManage />} />
            <Route path="tech-stacks" element={<TechStackManage />} />
            <Route path="showcases" element={<ShowcaseManage />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </ConfigProvider>
  );
};

export default App;
