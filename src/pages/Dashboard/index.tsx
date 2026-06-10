import React, { useEffect, useState, useRef, useCallback } from 'react';
import ReactECharts from 'echarts-for-react';
import SnapNav from '../../components/SnapNav/SnapNav';
import InkProgress from '../../components/InkProgress/InkProgress';
import InkTag from '../../components/InkTag/InkTag';
import { portfolioApi } from '../../api/portfolio';
import type { Project, TechStack, Showcase } from '../../types';
import styles from './Dashboard.module.css';

const Dashboard: React.FC = () => {
  const [projects, setProjects] = useState<Project[]>([]);
  const [techStacks, setTechStacks] = useState<TechStack[]>([]);
  const [showcases, setShowcases] = useState<Showcase[]>([]);
  const [currentProject, setCurrentProject] = useState(0);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    Promise.all([
      portfolioApi.getProjects().catch(() => ({ data: [] })),
      portfolioApi.getTechStacks().catch(() => ({ data: [] })),
      portfolioApi.getShowcases().catch(() => ({ data: [] })),
    ]).then(([pRes, tRes, sRes]) => {
      setProjects((pRes as any).data || []);
      setTechStacks((tRes as any).data || []);
      setShowcases((sRes as any).data || []);
    });
  }, []);

  const prevProject = () => setCurrentProject((i) => Math.max(0, i - 1));
  const nextProject = () => setCurrentProject((i) => Math.min(projects.length - 1, i + 1));

  const handleKeyDown = useCallback((e: KeyboardEvent) => {
    if (e.key === 'ArrowLeft') prevProject();
    if (e.key === 'ArrowRight') nextProject();
  }, []);

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [handleKeyDown]);

  const project = projects[currentProject];

  // Radar chart option
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

  // Heatmap option
  const heatmapOption = {
    grid: { top: 10, bottom: 30, left: 40, right: 10 },
    xAxis: { type: 'category', show: false },
    yAxis: { type: 'category', data: ['日', '一', '二', '三', '四', '五', '六'], axisLabel: { fontSize: 10, color: '#999' } },
    visualMap: {
      min: 0, max: 8, show: false,
      inRange: { color: ['#FAFAF8', '#E5E5E5', '#999999', '#666666', '#333333', '#0A0A0A'] },
    },
    series: [{
      type: 'heatmap',
      data: (() => {
        const data: [number, number, number][] = [];
        const today = new Date();
        const start = new Date(today.getFullYear(), 0, 1);
        for (let i = 0; i < 365; i++) {
          const d = new Date(start);
          d.setDate(d.getDate() + i);
          if (d > today) break;
          data.push([Math.floor(i / 7), i % 7, Math.floor(Math.random() * 8)]);
        }
        return data;
      })(),
      itemStyle: { borderRadius: 1, borderWidth: 1, borderColor: '#FAFAF8' },
    }],
  };

  return (
    <div className={styles.snapContainer} ref={containerRef}>
      <SnapNav containerRef={containerRef} count={5} />

      {/* Screen 1: Hero */}
      <section className={styles.hero}>
        <div className={styles.heroLabel}>TECH PORTFOLIO · {new Date().getFullYear()}</div>
        <div className={styles.heroTitle}>墨</div>
        <div className={styles.heroDivider} />
        <div className={styles.heroSub}>技术 · 作品 · 履历</div>
        <div className={styles.scrollHint}>
          <div className={styles.scrollLine} />
          <div className={styles.scrollText}>SCROLL</div>
        </div>
      </section>

      {/* Screen 2: Stats */}
      <section className={styles.stats}>
        <div className={styles.statsLabel}>OVERVIEW</div>
        <div className={styles.statsRow}>
          <div className={styles.statItem}>
            <div className={styles.statNumber}>{projects.length}</div>
            <div className={styles.statDivider} />
            <div className={styles.statLabel}>项目</div>
          </div>
          <div className={styles.statItem}>
            <div className={styles.statNumber}>{techStacks.length}</div>
            <div className={styles.statDivider} />
            <div className={styles.statLabel}>技术栈</div>
          </div>
          <div className={styles.statItem}>
            <div className={styles.statNumber}>{showcases.length}</div>
            <div className={styles.statDivider} />
            <div className={styles.statLabel}>展示</div>
          </div>
        </div>
      </section>

      {/* Screen 3: Featured Project */}
      <section className={styles.projects}>
        <div style={{ width: '100%', flex: 1, display: 'flex', flexDirection: 'column' }}>
          <div className={styles.projectsInner}>
            <div className={styles.projectImage}>
              {project?.coverImage && <img src={project.coverImage} alt={project.title} />}
              <div className={styles.projectImageOverlay} />
              <div className={styles.projectNumber}>{String(currentProject + 1).padStart(2, '0')}</div>
              <div className={styles.projectInfo}>
                <div className={styles.projectTitle}>{project?.title || '暂无项目'}</div>
                <div className={styles.projectDesc}>{project?.description?.substring(0, 100) || ''}</div>
                <div className={styles.projectTags}>
                  {project?.techStack?.split(',').map((t) => (
                    <InkTag key={t} variant="dark">{t.trim()}</InkTag>
                  ))}
                </div>
              </div>
            </div>
          </div>
          <div className={styles.projectNav}>
            <span className={styles.projectNavLink} onClick={prevProject}>← PREV</span>
            <span className={styles.projectNavCount}>{currentProject + 1} / {projects.length}</span>
            <span className={styles.projectNavLink} onClick={nextProject}>NEXT →</span>
          </div>
        </div>
      </section>

      {/* Screen 4: Tech Stack */}
      <section className={styles.techStack}>
        <div className={styles.techLeft}>
          <div className={styles.techLabel}>TECH STACK</div>
          <div className={styles.techTitle}>技术栈</div>
          {techStacks.slice(0, 6).map((ts) => (
            <InkProgress key={ts.id} label={ts.name} value={ts.proficiency} />
          ))}
        </div>
        <div className={styles.techRight}>
          {techStacks.length > 0 && (
            <ReactECharts option={radarOption} theme="ink" style={{ width: '100%', height: 300 }} />
          )}
        </div>
      </section>

      {/* Screen 5: Heatmap */}
      <section className={styles.heatmap}>
        <div className={styles.heatmapLabel}>COMMITS</div>
        <ReactECharts option={heatmapOption} theme="ink" style={{ height: 160, width: '100%' }} />
        <div className={styles.heatmapLegend}>
          <span>少</span>
          {['#FAFAF8', '#E5E5E5', '#999999', '#666666', '#333333', '#0A0A0A'].map((c) => (
            <div key={c} className={styles.legendBlock} style={{ backgroundColor: c, border: c === '#FAFAF8' ? '1px solid #E5E5E5' : 'none' }} />
          ))}
          <span>多</span>
        </div>
      </section>
    </div>
  );
};

export default Dashboard;
