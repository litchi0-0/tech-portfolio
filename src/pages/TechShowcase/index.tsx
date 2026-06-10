import React, { useEffect, useState, useRef } from 'react';
import ReactECharts from 'echarts-for-react';
import SnapNav from '../../components/SnapNav/SnapNav';
import InkProgress from '../../components/InkProgress/InkProgress';
import { portfolioApi } from '../../api/portfolio';
import type { TechStack } from '../../types';
import styles from './TechShowcase.module.css';

const categoryLabels: Record<string, string> = {
  frontend: '前端 FRONTEND', backend: '后端 BACKEND', database: '数据库 DATABASE',
  devops: 'DevOps', other: '其他 OTHER',
};

const TechShowcase: React.FC = () => {
  const [techStacks, setTechStacks] = useState<TechStack[]>([]);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    portfolioApi.getTechStacks().then((res: any) => setTechStacks(res.data || [])).catch(() => {});
  }, []);

  const grouped = techStacks.reduce((acc, ts) => {
    const cat = ts.category || 'other';
    if (!acc[cat]) acc[cat] = [];
    acc[cat].push(ts);
    return acc;
  }, {} as Record<string, TechStack[]>);

  const categories = Object.keys(grouped);
  const screenCount = 1 + categories.length;

  const scrollToCategory = (cat: string) => {
    const idx = categories.indexOf(cat);
    if (idx < 0) return;
    const container = containerRef.current;
    if (!container) return;
    const sections = container.querySelectorAll('section');
    sections[idx + 1]?.scrollIntoView({ behavior: 'smooth' });
  };

  const radarOption = {
    radar: {
      indicator: techStacks.slice(0, 12).map((ts) => ({ name: ts.name, max: 100 })),
      splitLine: { lineStyle: { color: '#E5E5E5' } },
      splitArea: { show: false },
      axisLine: { lineStyle: { color: '#E5E5E5' } },
      name: { textStyle: { color: '#666', fontSize: 11 } },
    },
    series: [{
      type: 'radar',
      data: [{
        value: techStacks.slice(0, 12).map((ts) => ts.proficiency),
        areaStyle: { color: 'rgba(10,10,10,0.06)' },
        lineStyle: { color: '#0A0A0A', width: 1 },
        itemStyle: { color: '#A85A4A' },
      }],
    }],
  };

  return (
    <div className={styles.container} ref={containerRef}>
      <SnapNav containerRef={containerRef} count={screenCount} />

      {/* Screen 1: Radar overview */}
      <section className={`${styles.screen} ${styles.screenLight}`}>
        <div className={styles.label}>TECH SHOWCASE</div>
        <div className={styles.title}>技术图谱</div>
        <div className={styles.radarWrap}>
          <ReactECharts option={radarOption} theme="ink" style={{ height: 300 }} />
        </div>
        <div className={styles.categories}>
          {categories.map((cat) => (
            <button key={cat} className={styles.catBtn} onClick={() => scrollToCategory(cat)}>
              {categoryLabels[cat] || cat}
            </button>
          ))}
        </div>
      </section>

      {/* Category screens */}
      {categories.map((cat) => (
        <section key={cat} className={`${styles.screen} ${styles.screenLight}`}>
          <div className={styles.catLabel}>{categoryLabels[cat] || cat}</div>
          <div className={styles.catTitle}>{(categoryLabels[cat] || cat).split(' ')[0]}</div>
          <div style={{ width: '100%', maxWidth: 600 }}>
            {grouped[cat].map((ts) => (
              <InkProgress key={ts.id} label={ts.name} value={ts.proficiency} />
            ))}
          </div>
        </section>
      ))}
    </div>
  );
};

export default TechShowcase;
