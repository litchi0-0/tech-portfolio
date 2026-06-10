import React, { useEffect, useState } from 'react';
import { Row, Col, Card, Statistic, Typography, Spin, Empty, Tag, Avatar, Divider } from 'antd';
import { ProjectOutlined, CodeOutlined, AppstoreOutlined, ThunderboltOutlined } from '@ant-design/icons';
import ReactECharts from 'echarts-for-react';
import { portfolioApi } from '../../api/portfolio';
import type { Project, TechStack, Showcase } from '../../types';

const { Title, Paragraph, Text } = Typography;

const Dashboard: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [projects, setProjects] = useState<Project[]>([]);
  const [techStacks, setTechStacks] = useState<TechStack[]>([]);
  const [showcases, setShowcases] = useState<Showcase[]>([]);

  useEffect(() => {
    Promise.all([
      portfolioApi.getProjects().catch(() => ({ data: [] })),
      portfolioApi.getTechStacks().catch(() => ({ data: [] })),
      portfolioApi.getShowcases().catch(() => ({ data: [] })),
    ]).then(([projectsRes, techStacksRes, showcasesRes]) => {
      setProjects((projectsRes as any).data || []);
      setTechStacks((techStacksRes as any).data || []);
      setShowcases((showcasesRes as any).data || []);
    }).finally(() => setLoading(false));
  }, []);

  if (loading) return <div style={{ display: 'flex', justifyContent: 'center', padding: 100 }}><Spin size="large" /></div>;

  return (
    <div>
      {/* Hero Section */}
      <div style={{ background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', padding: '80px 24px', textAlign: 'center', color: '#fff' }}>
        <Title level={1} style={{ color: '#fff', marginBottom: 16 }}>技术展示作品集</Title>
        <Paragraph style={{ color: 'rgba(255,255,255,0.85)', fontSize: 18, maxWidth: 600, margin: '0 auto' }}>
          全栈开发者的技术积累与项目展示
        </Paragraph>
      </div>

      {/* Statistics */}
      <div style={{ maxWidth: 1200, margin: '-40px auto 0', padding: '0 24px' }}>
        <Row gutter={[24, 24]}>
          <Col xs={24} sm={8}>
            <Card hoverable>
              <Statistic title="项目数量" value={projects.length} prefix={<ProjectOutlined />} />
            </Card>
          </Col>
          <Col xs={24} sm={8}>
            <Card hoverable>
              <Statistic title="技术栈" value={techStacks.length} prefix={<CodeOutlined />} />
            </Card>
          </Col>
          <Col xs={24} sm={8}>
            <Card hoverable>
              <Statistic title="展示作品" value={showcases.length} prefix={<AppstoreOutlined />} />
            </Card>
          </Col>
        </Row>
      </div>

      {/* Latest Projects */}
      <div style={{ maxWidth: 1200, margin: '40px auto', padding: '0 24px' }}>
        <Title level={3}>最新项目</Title>
        {projects.length === 0 ? <Empty description="暂无项目" /> : (
          <Row gutter={[24, 24]}>
            {projects.slice(0, 6).map(p => (
              <Col xs={24} sm={12} md={8} key={p.id}>
                <Card hoverable cover={p.coverImage ? <img alt={p.title} src={p.coverImage} style={{ height: 200, objectFit: 'cover' }} /> : undefined}>
                  <Card.Meta title={p.title} description={p.description?.substring(0, 80)} />
                  <div style={{ marginTop: 12 }}>
                    {p.techStack?.split(',').map(t => <Tag key={t} color="blue">{t.trim()}</Tag>)}
                  </div>
                </Card>
              </Col>
            ))}
          </Row>
        )}
      </div>

      {/* Tech Stack Overview */}
      <div style={{ maxWidth: 1200, margin: '0 auto 40px', padding: '0 24px' }}>
        <Title level={3}>技术栈概览</Title>
        {techStacks.length === 0 ? <Empty description="暂无技术栈" /> : (
          <Row gutter={[24, 24]}>
            {techStacks.map(ts => (
              <Col xs={24} sm={12} md={8} lg={6} key={ts.id}>
                <Card size="small" hoverable>
                  <Card.Meta
                    avatar={ts.icon ? <Avatar src={ts.icon} /> : <Avatar icon={<CodeOutlined />} />}
                    title={ts.name}
                    description={ts.description?.substring(0, 50)}
                  />
                  <div style={{ marginTop: 8 }}>
                    <Text type="secondary">熟练度: {ts.proficiency}%</Text>
                    <div style={{ background: '#f0f0f0', borderRadius: 4, height: 6, marginTop: 4 }}>
                      <div style={{ background: '#1890ff', borderRadius: 4, height: 6, width: `${ts.proficiency}%` }} />
                    </div>
                  </div>
                </Card>
              </Col>
            ))}
          </Row>
        )}
      </div>

      {/* GitHub Commit Heatmap */}
      <div style={{ maxWidth: 1200, margin: '0 auto 40px', padding: '0 24px' }}>
        <Title level={3}>GitHub 贡献</Title>
        <Card>
          <CommitHeatmap />
        </Card>
      </div>
    </div>
  );
};

// Simple commit heatmap component using ECharts
const CommitHeatmap: React.FC = () => {
  // Generate mock data for the heatmap (52 weeks x 7 days)
  const generateHeatmapData = () => {
    const data: [number, number, number][] = [];
    const now = new Date();
    const startDate = new Date(now.getFullYear(), 0, 1);
    for (let i = 0; i < 365; i++) {
      const date = new Date(startDate);
      date.setDate(date.getDate() + i);
      if (date > now) break;
      const week = Math.floor(i / 7);
      const day = i % 7;
      const commits = Math.floor(Math.random() * 8);
      data.push([week, day, commits]);
    }
    return data;
  };

  const option = {
    tooltip: { formatter: (params: any) => `${params.value[2]} 次提交` },
    grid: { top: 10, bottom: 30, left: 40, right: 10 },
    xAxis: { type: 'category', show: false },
    yAxis: { type: 'category', data: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'], axisLabel: { fontSize: 10 } },
    visualMap: { min: 0, max: 8, show: false, inRange: { color: ['#ebedf0', '#9be9a8', '#40c463', '#30a14e', '#216e39'] } },
    series: [{
      type: 'heatmap',
      data: generateHeatmapData(),
      itemStyle: { borderRadius: 2 },
    }],
  };

  return <ReactECharts option={option} style={{ height: 180 }} />;
};

export default Dashboard;
