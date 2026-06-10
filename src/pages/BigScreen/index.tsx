import React from 'react';
import ReactECharts from 'echarts-for-react';
import styles from './BigScreen.module.css';

const BigScreen: React.FC = () => {
  // Bar chart: tech stack usage frequency - monochrome grayscale, accent on highest bar
  const barData = [
    { name: 'React', value: 120 },
    { name: 'Vue', value: 80 },
    { name: 'Spring Boot', value: 95 },
    { name: 'Node.js', value: 60 },
    { name: 'Python', value: 45 },
    { name: 'Go', value: 35 },
  ];
  const maxBarValue = Math.max(...barData.map(d => d.value));

  const barOption = {
    tooltip: { trigger: 'axis' },
    grid: { top: 10, right: 16, bottom: 24, left: 48 },
    xAxis: {
      type: 'category',
      data: barData.map(d => d.name),
      axisLine: { lineStyle: { color: '#1A1A1A' } },
      axisLabel: { color: '#666666', fontSize: 11 },
      axisTick: { show: false },
    },
    yAxis: {
      type: 'value',
      axisLine: { show: false },
      axisTick: { show: false },
      axisLabel: { color: '#666666', fontSize: 11 },
      splitLine: { lineStyle: { color: '#1A1A1A', type: 'dashed' } },
    },
    series: [{
      type: 'bar',
      data: barData.map(d => ({
        value: d.value,
        itemStyle: {
          color: d.value === maxBarValue ? '#A85A4A' : '#333333',
          borderRadius: [2, 2, 0, 0],
        },
      })),
      barWidth: '40%',
    }],
  };

  // Line chart: annual commit trend
  const lineOption = {
    tooltip: { trigger: 'axis' },
    grid: { top: 10, right: 16, bottom: 24, left: 48 },
    xAxis: {
      type: 'category',
      data: ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月'],
      axisLine: { lineStyle: { color: '#1A1A1A' } },
      axisLabel: { color: '#666666', fontSize: 11 },
      axisTick: { show: false },
    },
    yAxis: {
      type: 'value',
      axisLine: { show: false },
      axisTick: { show: false },
      axisLabel: { color: '#666666', fontSize: 11 },
      splitLine: { lineStyle: { color: '#1A1A1A', type: 'dashed' } },
    },
    series: [{
      type: 'line',
      data: [150, 180, 220, 280, 350, 310, 290, 320, 380, 420, 390, 450],
      smooth: true,
      symbol: 'circle',
      symbolSize: 4,
      lineStyle: { width: 1, color: '#666666' },
      itemStyle: { color: '#999999', borderWidth: 1 },
      areaStyle: { color: 'rgba(51,51,51,0.15)' },
    }],
  };

  // Pie/donut chart: project type distribution - grayscale
  const pieOption = {
    tooltip: { trigger: 'item' },
    series: [{
      type: 'pie',
      radius: ['40%', '70%'],
      center: ['50%', '55%'],
      data: [
        { value: 8, name: '全栈项目', itemStyle: { color: '#333333' } },
        { value: 5, name: '前端项目', itemStyle: { color: '#666666' } },
        { value: 4, name: '后端项目', itemStyle: { color: '#999999' } },
        { value: 3, name: '移动端项目', itemStyle: { color: '#1A1A1A', borderColor: '#333333', borderWidth: 1 } },
      ],
      label: { color: '#666666', fontSize: 11 },
      itemStyle: { borderColor: '#0A0A0A', borderWidth: 2 },
    }],
  };

  return (
    <div className={styles.page}>
      <div className={styles.header}>
        <div className={styles.label}>DATA VISUALIZATION</div>
        <h1 className={styles.title}>数据大屏</h1>
      </div>

      <div className={styles.grid}>
        {/* Bar chart */}
        <div className={styles.chartCard}>
          <div className={styles.chartTitle}>技术栈使用频率</div>
          <div className={styles.chartWrap}>
            <ReactECharts option={barOption} style={{ height: '100%' }} theme="ink" />
          </div>
        </div>

        {/* Line chart */}
        <div className={styles.chartCard}>
          <div className={styles.chartTitle}>年度提交趋势</div>
          <div className={styles.chartWrap}>
            <ReactECharts option={lineOption} style={{ height: '100%' }} theme="ink" />
          </div>
        </div>

        {/* Pie/donut chart */}
        <div className={styles.chartCard}>
          <div className={styles.chartTitle}>项目类型分布</div>
          <div className={styles.chartWrap}>
            <ReactECharts option={pieOption} style={{ height: '100%' }} theme="ink" />
          </div>
        </div>

        {/* Code quality score - no gauge ring */}
        <div className={styles.chartCard}>
          <div className={styles.chartTitle}>代码质量评分</div>
          <div className={styles.scoreContainer}>
            <div className={styles.scoreNumber}>92</div>
            <div className={styles.scoreDivider} />
            <div className={styles.scoreTotal}>/ 100</div>
            <div className={styles.scoreLabel}>QUALITY SCORE</div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default BigScreen;
