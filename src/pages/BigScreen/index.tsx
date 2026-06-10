import React, { useEffect, useState } from 'react';
import { Row, Col, Card, Typography, Spin } from 'antd';
import ReactECharts from 'echarts-for-react';
import { portfolioApi } from '../../api/portfolio';
import type { Showcase } from '../../types';

const { Title } = Typography;

const BigScreen: React.FC = () => {
  const [showcases, setShowcases] = useState<Showcase[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    portfolioApi.getShowcases('bigscreen').then((res: any) => setShowcases(res.data || [])).catch(() => {}).finally(() => setLoading(false));
  }, []);

  if (loading) return <div style={{ display: 'flex', justifyContent: 'center', padding: 100 }}><Spin size="large" /></div>;

  // Hardcoded demo charts for the big screen showcase
  const barOption = {
    backgroundColor: 'transparent',
    title: { text: '技术栈使用频率', textStyle: { color: '#fff' } },
    tooltip: {},
    xAxis: { type: 'category', data: ['React', 'Vue', 'Spring Boot', 'Node.js', 'Python', 'Go'], axisLabel: { color: '#aaa' } },
    yAxis: { type: 'value', axisLabel: { color: '#aaa' }, splitLine: { lineStyle: { color: 'rgba(255,255,255,0.1)' } } },
    series: [{ type: 'bar', data: [120, 80, 95, 60, 45, 35], itemStyle: { color: '#5470c6', borderRadius: [4, 4, 0, 0] } }],
  };

  const pieOption = {
    backgroundColor: 'transparent',
    title: { text: '项目类型分布', textStyle: { color: '#fff' } },
    tooltip: { trigger: 'item' },
    series: [{
      type: 'pie', radius: ['40%', '70%'],
      data: [
        { value: 8, name: '全栈项目' },
        { value: 5, name: '前端项目' },
        { value: 4, name: '后端项目' },
        { value: 3, name: '移动端项目' },
      ],
      label: { color: '#aaa' },
    }],
  };

  const lineOption = {
    backgroundColor: 'transparent',
    title: { text: '年度提交趋势', textStyle: { color: '#fff' } },
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月'], axisLabel: { color: '#aaa' } },
    yAxis: { type: 'value', axisLabel: { color: '#aaa' }, splitLine: { lineStyle: { color: 'rgba(255,255,255,0.1)' } } },
    series: [
      { type: 'line', data: [150, 180, 220, 280, 350, 310, 290, 320, 380, 420, 390, 450], smooth: true, areaStyle: { opacity: 0.3 }, itemStyle: { color: '#91cc75' } },
    ],
  };

  const gaugeOption = {
    backgroundColor: 'transparent',
    title: { text: '代码质量评分', textStyle: { color: '#fff' } },
    series: [{
      type: 'gauge',
      detail: { valueAnimation: true, formatter: '{value}%', color: '#fff' },
      data: [{ value: 92, name: '质量分' }],
      axisLine: { lineStyle: { width: 10 } },
      title: { offsetCenter: [0, '70%'], color: '#aaa' },
    }],
  };

  return (
    <div style={{ background: '#0a0e27', minHeight: 'calc(100vh - 64px - 69px)', padding: '20px' }}>
      <Title level={2} style={{ color: '#fff', textAlign: 'center', marginBottom: 24 }}>
        {showcases.length > 0 ? showcases[0].title : '数据可视化大屏'}
      </Title>

      <Row gutter={[16, 16]}>
        <Col xs={24} md={12}>
          <Card style={{ background: 'rgba(255,255,255,0.05)', border: '1px solid rgba(255,255,255,0.1)' }}>
            <ReactECharts option={barOption} style={{ height: 300 }} />
          </Card>
        </Col>
        <Col xs={24} md={12}>
          <Card style={{ background: 'rgba(255,255,255,0.05)', border: '1px solid rgba(255,255,255,0.1)' }}>
            <ReactECharts option={pieOption} style={{ height: 300 }} />
          </Card>
        </Col>
        <Col xs={24} md={12}>
          <Card style={{ background: 'rgba(255,255,255,0.05)', border: '1px solid rgba(255,255,255,0.1)' }}>
            <ReactECharts option={lineOption} style={{ height: 300 }} />
          </Card>
        </Col>
        <Col xs={24} md={12}>
          <Card style={{ background: 'rgba(255,255,255,0.05)', border: '1px solid rgba(255,255,255,0.1)' }}>
            <ReactECharts option={gaugeOption} style={{ height: 300 }} />
          </Card>
        </Col>
      </Row>
    </div>
  );
};

export default BigScreen;
