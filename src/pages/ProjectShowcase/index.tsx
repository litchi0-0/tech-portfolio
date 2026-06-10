import React, { useEffect, useState } from 'react';
import { Row, Col, Card, Tag, Typography, Spin, Empty, Button, Space } from 'antd';
import { EyeOutlined, GithubOutlined, LinkOutlined } from '@ant-design/icons';
import { portfolioApi } from '../../api/portfolio';
import type { Project } from '../../types';

const { Title, Paragraph } = Typography;

const categoryColors: Record<string, string> = {
  fullstack: 'purple', frontend: 'blue', backend: 'green', mobile: 'orange',
};

const ProjectShowcase: React.FC = () => {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<string>('all');

  useEffect(() => {
    portfolioApi.getProjects().then((res: any) => setProjects(res.data || [])).catch(() => {}).finally(() => setLoading(false));
  }, []);

  if (loading) return <div style={{ display: 'flex', justifyContent: 'center', padding: 100 }}><Spin size="large" /></div>;

  const categories = ['all', ...Array.from(new Set(projects.map(p => p.category).filter(Boolean)))];
  const filtered = filter === 'all' ? projects : projects.filter(p => p.category === filter);

  return (
    <div style={{ maxWidth: 1200, margin: '0 auto', padding: '40px 24px' }}>
      <Title level={2}>项目展示</Title>

      <Space style={{ marginBottom: 24 }} wrap>
        {categories.map(cat => (
          <Button key={cat} type={filter === cat ? 'primary' : 'default'} onClick={() => setFilter(cat)}>
            {cat === 'all' ? '全部' : cat}
          </Button>
        ))}
      </Space>

      {filtered.length === 0 ? <Empty description="暂无项目" /> : (
        <Row gutter={[24, 24]}>
          {filtered.map(p => (
            <Col xs={24} sm={12} md={8} key={p.id}>
              <Card
                hoverable
                cover={
                  p.coverImage ? (
                    <div style={{ height: 200, overflow: 'hidden', background: '#f0f0f0', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                      <img alt={p.title} src={p.coverImage} style={{ width: '100%', height: 200, objectFit: 'cover' }} />
                    </div>
                  ) : (
                    <div style={{ height: 200, background: 'linear-gradient(135deg, #667eea, #764ba2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                      <EyeOutlined style={{ fontSize: 48, color: '#fff' }} />
                    </div>
                  )
                }
                actions={[
                  p.demoUrl ? <LinkOutlined key="demo" onClick={() => window.open(p.demoUrl)} /> : null,
                  p.repoUrl ? <GithubOutlined key="repo" onClick={() => window.open(p.repoUrl)} /> : null,
                ].filter(Boolean)}
              >
                <Card.Meta
                  title={<Space>{p.title} {p.category && <Tag color={categoryColors[p.category] || 'default'}>{p.category}</Tag>}</Space>}
                  description={<Paragraph ellipsis={{ rows: 3 }}>{p.description}</Paragraph>}
                />
                <div style={{ marginTop: 12 }}>
                  {p.techStack?.split(',').map(t => <Tag key={t}>{t.trim()}</Tag>)}
                </div>
              </Card>
            </Col>
          ))}
        </Row>
      )}
    </div>
  );
};

export default ProjectShowcase;
