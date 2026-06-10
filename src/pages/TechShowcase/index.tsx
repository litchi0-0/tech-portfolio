import React, { useEffect, useState } from 'react';
import { Row, Col, Card, Tag, Typography, Spin, Empty, Progress } from 'antd';
import { CodeOutlined } from '@ant-design/icons';
import ReactECharts from 'echarts-for-react';
import { portfolioApi } from '../../api/portfolio';
import type { TechStack } from '../../types';

const { Title } = Typography;

const TechShowcase: React.FC = () => {
  const [techStacks, setTechStacks] = useState<TechStack[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    portfolioApi.getTechStacks().then((res: any) => setTechStacks(res.data || [])).catch(() => {}).finally(() => setLoading(false));
  }, []);

  if (loading) return <div style={{ display: 'flex', justifyContent: 'center', padding: 100 }}><Spin size="large" /></div>;

  // Group by category
  const grouped = techStacks.reduce((acc, ts) => {
    const cat = ts.category || 'other';
    if (!acc[cat]) acc[cat] = [];
    acc[cat].push(ts);
    return acc;
  }, {} as Record<string, TechStack[]>);

  const categoryLabels: Record<string, string> = {
    frontend: '前端', backend: '后端', database: '数据库', devops: 'DevOps', other: '其他'
  };

  // Radar chart option
  const radarOption = {
    tooltip: {},
    radar: {
      indicator: techStacks.slice(0, 12).map(ts => ({ name: ts.name, max: 100 })),
    },
    series: [{
      type: 'radar',
      data: [{ value: techStacks.slice(0, 12).map(ts => ts.proficiency), name: '熟练度' }],
    }],
  };

  return (
    <div style={{ maxWidth: 1200, margin: '0 auto', padding: '40px 24px' }}>
      <Title level={2}>技术栈展示</Title>

      {techStacks.length > 0 && (
        <Card style={{ marginBottom: 32 }}>
          <ReactECharts option={radarOption} style={{ height: 400 }} />
        </Card>
      )}

      {Object.entries(grouped).map(([category, items]) => (
        <div key={category} style={{ marginBottom: 32 }}>
          <Title level={3}>{categoryLabels[category] || category}</Title>
          <Row gutter={[24, 24]}>
            {items.map(ts => (
              <Col xs={24} sm={12} md={8} lg={6} key={ts.id}>
                <Card hoverable>
                  <div style={{ display: 'flex', alignItems: 'center', marginBottom: 12 }}>
                    <CodeOutlined style={{ fontSize: 24, marginRight: 12, color: '#1890ff' }} />
                    <Title level={5} style={{ margin: 0 }}>{ts.name}</Title>
                  </div>
                  <Progress percent={ts.proficiency} strokeColor={{ '0%': '#108ee9', '100%': '#87d068' }} />
                  {ts.description && <p style={{ color: '#666', marginTop: 8, fontSize: 13 }}>{ts.description}</p>}
                </Card>
              </Col>
            ))}
          </Row>
        </div>
      ))}

      {techStacks.length === 0 && <Empty description="暂无技术栈数据" />}
    </div>
  );
};

export default TechShowcase;
