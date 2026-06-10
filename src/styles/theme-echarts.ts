import { registerTheme } from 'echarts/core';

const inkTheme = {
  color: ['#0A0A0A', '#333333', '#666666', '#999999', '#E5E5E5', '#A85A4A'],
  backgroundColor: 'transparent',
  textStyle: {
    color: '#666666',
    fontFamily: "'Noto Sans SC', system-ui, sans-serif",
  },
  title: {
    textStyle: { color: '#0A0A0A', fontFamily: "'Noto Serif SC', Georgia, serif", fontWeight: 300 },
    subtextStyle: { color: '#999999' },
  },
  line: {
    itemStyle: { borderWidth: 1 },
    lineStyle: { width: 1 },
    symbolSize: 4,
    symbol: 'circle',
    smooth: true,
  },
  bar: {
    itemStyle: {
      barBorderWidth: 0,
      barBorderColor: '#333333',
    },
  },
  pie: {
    itemStyle: {
      borderWidth: 1,
      borderColor: '#FAFAF8',
    },
  },
  radar: {
    name: { textStyle: { color: '#666666', fontSize: 11 } },
    splitLine: { lineStyle: { color: '#E5E5E5' } },
    splitArea: { show: false },
    axisLine: { lineStyle: { color: '#E5E5E5' } },
  },
  heatmap: {
    itemStyle: {
      borderWidth: 1,
      borderColor: '#FAFAF8',
    },
  },
  tooltip: {
    backgroundColor: '#0A0A0A',
    borderColor: '#333333',
    textStyle: { color: '#FAFAF8', fontSize: 12 },
  },
  legend: {
    textStyle: { color: '#666666' },
  },
  categoryAxis: {
    axisLine: { show: true, lineStyle: { color: '#E5E5E5' } },
    axisTick: { show: false },
    axisLabel: { color: '#999999', fontSize: 11 },
    splitLine: { show: false },
  },
  valueAxis: {
    axisLine: { show: false },
    axisTick: { show: false },
    axisLabel: { color: '#999999', fontSize: 11 },
    splitLine: { lineStyle: { color: '#F0F0F0', type: 'dashed' } },
  },
};

registerTheme('ink', inkTheme);

export default inkTheme;
