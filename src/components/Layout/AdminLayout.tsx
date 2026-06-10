import React from 'react';
import { Layout, Menu, Button, Avatar, Dropdown } from 'antd';
import { Outlet, useLocation, useNavigate } from 'react-router-dom';
import {
  DashboardOutlined,
  ProjectOutlined,
  CodeOutlined,
  AppstoreOutlined,
  LogoutOutlined,
  UserOutlined,
} from '@ant-design/icons';

const { Sider, Header, Content } = Layout;

const siderItems = [
  { key: '/admin', icon: <DashboardOutlined />, label: '仪表盘' },
  { key: '/admin/projects', icon: <ProjectOutlined />, label: '项目管理' },
  { key: '/admin/tech-stacks', icon: <CodeOutlined />, label: '技术栈管理' },
  { key: '/admin/showcases', icon: <AppstoreOutlined />, label: '展示项管理' },
];

interface AdminLayoutProps {
  onLogout: () => void;
  username?: string;
}

const AdminLayout: React.FC<AdminLayoutProps> = ({ onLogout, username }) => {
  const location = useLocation();
  const navigate = useNavigate();

  const dropdownItems = [
    { key: 'home', label: '返回前台', onClick: () => navigate('/') },
    { key: 'logout', label: '退出登录', onClick: onLogout, icon: <LogoutOutlined /> },
  ];

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Sider theme="dark" width={200}>
        <div style={{ height: 64, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontSize: 18, fontWeight: 'bold' }}>
          管理后台
        </div>
        <Menu
          theme="dark"
          mode="inline"
          selectedKeys={[location.pathname]}
          items={siderItems}
          onClick={({ key }) => navigate(key)}
        />
      </Sider>
      <Layout>
        <Header style={{ padding: '0 24px', background: '#fff', display: 'flex', justifyContent: 'flex-end', alignItems: 'center', boxShadow: '0 1px 4px rgba(0,0,0,0.1)' }}>
          <Dropdown menu={{ items: dropdownItems }} placement="bottomRight">
            <div style={{ cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8 }}>
              <Avatar icon={<UserOutlined />} />
              <span>{username || '管理员'}</span>
            </div>
          </Dropdown>
        </Header>
        <Content style={{ margin: 16, padding: 24, background: '#fff', borderRadius: 8, minHeight: 280 }}>
          <Outlet />
        </Content>
      </Layout>
    </Layout>
  );
};

export default AdminLayout;
