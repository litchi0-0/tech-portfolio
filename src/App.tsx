import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ConfigProvider } from 'antd';
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

const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();
  if (loading) return null;
  return isAuthenticated ? <>{children}</> : <Navigate to="/login" replace />;
};

const App: React.FC = () => {
  const { isAuthenticated, logout, user } = useAuth();

  return (
    <ConfigProvider locale={zhCN}>
      <BrowserRouter>
        <Routes>
          {/* Public routes */}
          <Route element={<PublicLayout />}>
            <Route path="/" element={<Dashboard />} />
            <Route path="/tech" element={<TechShowcase />} />
            <Route path="/projects" element={<ProjectShowcase />} />
            <Route path="/bigscreen" element={<BigScreen />} />
            <Route path="/table" element={<TableDemo />} />
            <Route path="/threejs" element={<ThreeJS />} />
          </Route>

          {/* Login */}
          <Route path="/login" element={<Login />} />

          {/* Admin routes */}
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
