import React from 'react';
import { Layout, Menu, Button } from 'antd';
import { Link, Outlet, useLocation, useNavigate } from 'react-router-dom';
import {
  HomeOutlined,
  CodeOutlined,
  ProjectOutlined,
  DashboardOutlined,
  TableOutlined,
  GithubOutlined,
} from '@ant-design/icons';

const { Header, Content, Footer } = Layout;

const menuItems = [
  { key: '/', icon: <HomeOutlined />, label: <Link to="/">首页</Link> },
  { key: '/tech', icon: <CodeOutlined />, label: <Link to="/tech">技术栈</Link> },
  { key: '/projects', icon: <ProjectOutlined />, label: <Link to="/projects">项目展示</Link> },
  { key: '/bigscreen', icon: <DashboardOutlined />, label: <Link to="/bigscreen">大屏展示</Link> },
  { key: '/table', icon: <TableOutlined />, label: <Link to="/table">表格展示</Link> },
  { key: '/threejs', icon: <GithubOutlined />, label: <Link to="/threejs">Three.js</Link> },
];

const PublicLayout: React.FC = () => {
  const location = useLocation();
  const navigate = useNavigate();

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Header style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 24px' }}>
        <div style={{ display: 'flex', alignItems: 'center' }}>
          <div style={{ color: '#fff', fontSize: 20, fontWeight: 'bold', marginRight: 40, whiteSpace: 'nowrap' }}>
            Portfolio
          </div>
          <Menu
            theme="dark"
            mode="horizontal"
            selectedKeys={[location.pathname]}
            items={menuItems}
            style={{ flex: 1, minWidth: 0 }}
          />
        </div>
        <Button type="link" onClick={() => navigate('/login')} style={{ color: '#fff' }}>
          管理后台
        </Button>
      </Header>
      <Content style={{ padding: '0', background: '#f0f2f5' }}>
        <Outlet />
      </Content>
      <Footer style={{ textAlign: 'center', background: '#001529', color: 'rgba(255,255,255,0.65)' }}>
        Portfolio ©{new Date().getFullYear()} - 技术展示作品集
      </Footer>
    </Layout>
  );
};

export default PublicLayout;
