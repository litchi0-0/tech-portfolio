import React, { useEffect, useState } from 'react';
import { Card, Row, Col, Typography, Spin } from 'antd';
import ReactECharts from 'echarts-for-react';
import { portfolioApi } from '../../api/portfolio';
import type { Showcase } from '../../types';

const { Title, Paragraph } = Typography;

const ThreeJS: React.FC = () => {
  const [showcases, setShowcases] = useState<Showcase[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    portfolioApi.getShowcases('threejs').then((res: any) => setShowcases(res.data || [])).catch(() => {}).finally(() => setLoading(false));
  }, []);

  if (loading) return <div style={{ display: 'flex', justifyContent: 'center', padding: 100 }}><Spin size="large" /></div>;

  const scatter3DOption = {
    backgroundColor: '#000',
    title: { text: '3D 技能散点图', textStyle: { color: '#fff' }, left: 'center' },
    tooltip: {},
    xAxis3D: { type: 'value', name: '熟练度' },
    yAxis3D: { type: 'value', name: '使用频率' },
    zAxis3D: { type: 'value', name: '项目数' },
    grid3D: { viewControl: { autoRotate: true } },
    series: [{
      type: 'scatter3D',
      data: [
        [90, 80, 12, 'React'], [85, 70, 10, 'TypeScript'], [80, 60, 8, 'Spring Boot'],
        [75, 50, 6, 'Node.js'], [70, 40, 5, 'Python'], [65, 55, 7, 'Vue'],
        [60, 30, 4, 'Go'], [55, 25, 3, 'Docker'], [50, 45, 6, 'MySQL'],
      ],
      symbolSize: (val: number[]) => val[2] * 3,
      itemStyle: { color: (params: any) => {
        const colors = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272', '#fc8452', '#9a60b4', '#ea7ccc'];
        return colors[params.dataIndex % colors.length];
      }},
    }],
  };

  return (
    <div style={{ maxWidth: 1200, margin: '0 auto', padding: '40px 24px' }}>
      <Title level={2}>{showcases.length > 0 ? showcases[0].title : 'Three.js 3D 展示'}</Title>
      <Paragraph type="secondary">
        {showcases.length > 0 ? showcases[0].description : '使用 ECharts GL 实现的 3D 数据可视化效果展示'}
      </Paragraph>

      <Row gutter={[24, 24]}>
        <Col span={24}>
          <Card>
            <ReactECharts option={scatter3DOption} style={{ height: 500 }} />
          </Card>
        </Col>
      </Row>

      {/* CSS 3D Transform demo */}
      <Card style={{ marginTop: 24 }}>
        <Title level={4}>CSS 3D 变换展示</Title>
        <div style={{ display: 'flex', justifyContent: 'center', padding: '40px 0' }}>
          <div style={{
            perspective: '800px',
          }}>
            <div style={{
              width: 200, height: 200, background: 'linear-gradient(135deg, #667eea, #764ba2)',
              borderRadius: 12, display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: '#fff', fontSize: 20, fontWeight: 'bold',
              transform: 'rotateX(15deg) rotateY(-15deg)',
              boxShadow: '10px 10px 30px rgba(0,0,0,0.3)',
              transition: 'transform 0.5s ease',
              cursor: 'pointer',
            }}
            onMouseEnter={e => { (e.target as HTMLElement).style.transform = 'rotateX(0deg) rotateY(0deg)'; }}
            onMouseLeave={e => { (e.target as HTMLElement).style.transform = 'rotateX(15deg) rotateY(-15deg)'; }}
            >
              3D Card
            </div>
          </div>
        </div>
      </Card>
    </div>
  );
};

export default ThreeJS;
