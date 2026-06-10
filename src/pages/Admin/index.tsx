import React, { useEffect, useState } from 'react';
import { Row, Col, Card, Statistic, Typography } from 'antd';
import { ProjectOutlined, CodeOutlined, AppstoreOutlined, UserOutlined } from '@ant-design/icons';
import { adminApi } from '../../api/admin';
import type { Project, TechStack, Showcase } from '../../types';

const { Title } = Typography;

const AdminDashboard: React.FC = () => {
  const [stats, setStats] = useState({ projects: 0, techStacks: 0, showcases: 0 });

  useEffect(() => {
    Promise.all([
      adminApi.getProjects(),
      adminApi.getTechStacks(),
      adminApi.getShowcases(),
    ]).then(([p, t, s]) => {
      setStats({
        projects: (p as any).data?.length || 0,
        techStacks: (t as any).data?.length || 0,
        showcases: (s as any).data?.length || 0,
      });
    }).catch(() => {});
  }, []);

  return (
    <div>
      <Title level={4}>管理仪表盘</Title>
      <Row gutter={[24, 24]}>
        <Col xs={24} sm={8}>
          <Card>
            <Statistic title="项目总数" value={stats.projects} prefix={<ProjectOutlined />} />
          </Card>
        </Col>
        <Col xs={24} sm={8}>
          <Card>
            <Statistic title="技术栈总数" value={stats.techStacks} prefix={<CodeOutlined />} />
          </Card>
        </Col>
        <Col xs={24} sm={8}>
          <Card>
            <Statistic title="展示项总数" value={stats.showcases} prefix={<AppstoreOutlined />} />
          </Card>
        </Col>
      </Row>
    </div>
  );
};

export default AdminDashboard;
