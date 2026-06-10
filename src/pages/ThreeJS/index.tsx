import React from 'react';
import ReactECharts from 'echarts-for-react';
import styles from './ThreeJS.module.css';

const ThreeJS: React.FC = () => {
  const scatter3DOption = {
    backgroundColor: 'transparent',
    tooltip: {},
    xAxis3D: {
      type: 'value',
      name: '熟练度',
      nameTextStyle: { color: '#666666', fontSize: 11 },
      axisLine: { lineStyle: { color: '#1A1A1A' } },
      axisLabel: { color: '#666666', fontSize: 10 },
      splitLine: { lineStyle: { color: '#1A1A1A' } },
    },
    yAxis3D: {
      type: 'value',
      name: '使用频率',
      nameTextStyle: { color: '#666666', fontSize: 11 },
      axisLine: { lineStyle: { color: '#1A1A1A' } },
      axisLabel: { color: '#666666', fontSize: 10 },
      splitLine: { lineStyle: { color: '#1A1A1A' } },
    },
    zAxis3D: {
      type: 'value',
      name: '项目数',
      nameTextStyle: { color: '#666666', fontSize: 11 },
      axisLine: { lineStyle: { color: '#1A1A1A' } },
      axisLabel: { color: '#666666', fontSize: 10 },
      splitLine: { lineStyle: { color: '#1A1A1A' } },
    },
    grid3D: {
      viewControl: { autoRotate: true, autoRotateSpeed: 4 },
      light: {
        main: { intensity: 1.2, shadow: false },
        ambient: { intensity: 0.3 },
      },
      axisLine: { lineStyle: { color: '#1A1A1A' } },
      axisPointer: { lineStyle: { color: '#333333' } },
      splitLine: { lineStyle: { color: '#1A1A1A' } },
      splitArea: { show: false },
      environment: 'transparent',
    },
    series: [{
      type: 'scatter3D',
      data: [
        { value: [90, 80, 12], name: 'React' },
        { value: [85, 70, 10], name: 'TypeScript' },
        { value: [80, 60, 8], name: 'Spring Boot' },
        { value: [75, 50, 6], name: 'Node.js' },
        { value: [70, 40, 5], name: 'Python' },
        { value: [65, 55, 7], name: 'Vue' },
        { value: [60, 30, 4], name: 'Go' },
        { value: [55, 25, 3], name: 'Docker' },
        { value: [50, 45, 6], name: 'MySQL' },
      ],
      symbolSize: (val: number[]) => val[2] * 4,
      itemStyle: {
        color: '#666666',
        opacity: 0.9,
      },
      label: {
        show: true,
        formatter: (params: any) => params.data.name,
        textStyle: {
          color: '#999999',
          fontSize: 10,
        },
      },
      emphasis: {
        itemStyle: {
          color: '#A85A4A',
        },
      },
    }],
  };

  return (
    <div className={styles.page}>
      <div className={styles.header}>
        <div className={styles.label}>3D SHOWCASE</div>
        <h1 className={styles.title}>三维展示</h1>
      </div>

      <div className={styles.chartContainer}>
        <ReactECharts
          option={scatter3DOption}
          style={{ height: '100%' }}
          theme="ink"
        />
      </div>

      <div className={styles.annotation}>
        技能三维分布 · 自动旋转
      </div>
    </div>
  );
};

export default ThreeJS;
