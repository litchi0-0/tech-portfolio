import React, { useEffect, useRef, useState, useCallback } from 'react';
import { portfolioApi } from '../../api/portfolio';
import type { Project } from '../../types';
import SnapNav from '../../components/SnapNav/SnapNav';
import InkTag from '../../components/InkTag/InkTag';
import styles from './ProjectShowcase.module.css';

const CATEGORY_LABELS: Record<string, string> = {
  all: '全部',
  frontend: '前端',
  fullstack: '全栈',
  backend: '后端',
};

const getCategoryLabel = (cat: string): string =>
  CATEGORY_LABELS[cat] || cat;

const ProjectShowcase: React.FC = () => {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<string>('all');
  const [activeIndex, setActiveIndex] = useState(0);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    portfolioApi
      .getProjects()
      .then((res) => setProjects(res.data?.data || []))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  // Extract unique categories from projects
  const categories = ['all', ...Array.from(new Set(projects.map((p) => p.category).filter(Boolean)))];

  // Filtered projects
  const filtered = filter === 'all' ? projects : projects.filter((p) => p.category === filter);

  // Reset active index when filter changes
  useEffect(() => {
    setActiveIndex(0);
    if (containerRef.current) {
      containerRef.current.scrollTop = 0;
    }
  }, [filter]);

  // Observe which slide is visible
  useEffect(() => {
    const container = containerRef.current;
    if (!container || filtered.length === 0) return;

    const sections = container.querySelectorAll('section');
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const idx = Array.from(sections as NodeListOf<HTMLElement>).indexOf(entry.target as HTMLElement);
            if (idx >= 0) setActiveIndex(idx);
          }
        });
      },
      { root: container, threshold: 0.5 }
    );

    sections.forEach((s) => observer.observe(s));
    return () => observer.disconnect();
  }, [filtered.length]);

  // Scroll to a specific slide
  const scrollToSlide = useCallback(
    (index: number) => {
      const container = containerRef.current;
      if (!container) return;
      const sections = container.querySelectorAll('section');
      sections[index]?.scrollIntoView({ behavior: 'smooth' });
    },
    []
  );

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'ArrowRight' || e.key === 'ArrowDown') {
        e.preventDefault();
        const next = Math.min(activeIndex + 1, filtered.length - 1);
        if (next !== activeIndex) scrollToSlide(next);
      } else if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
        e.preventDefault();
        const prev = Math.max(activeIndex - 1, 0);
        if (prev !== activeIndex) scrollToSlide(prev);
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [activeIndex, filtered.length, scrollToSlide]);

  const handlePrev = () => {
    if (activeIndex > 0) scrollToSlide(activeIndex - 1);
  };

  const handleNext = () => {
    if (activeIndex < filtered.length - 1) scrollToSlide(activeIndex + 1);
  };

  if (loading) {
    return (
      <div className={styles.root}>
        <div className={styles.loadingWrap}>
          <div className={styles.loadingSpinner} />
        </div>
      </div>
    );
  }

  return (
    <div className={styles.root}>
      {/* Header: title + filter pills */}
      <div className={styles.header}>
        <h1 className={styles.title}>作品集</h1>
        <div className={styles.filters}>
          {categories.map((cat) => (
            <button
              key={cat}
              className={`${styles.filterPill} ${filter === cat ? styles.filterActive : ''}`}
              onClick={() => setFilter(cat)}
            >
              {getCategoryLabel(cat)}
            </button>
          ))}
        </div>
      </div>

      {/* Main snap-scroll gallery */}
      {filtered.length === 0 ? (
        <div className={styles.emptyState}>
          <span className={styles.emptyIcon}>&#9744;</span>
          <span>暂无项目</span>
        </div>
      ) : (
        <>
          <div ref={containerRef} className={styles.snapContainer}>
            {filtered.map((project) => (
              <section key={project.id} className={styles.slide}>
                {/* Left: image area with dark gradient overlay */}
                <div className={styles.slideImage}>
                  {project.coverImage ? (
                    <>
                      <img src={project.coverImage} alt={project.title} />
                      <div className={styles.imageOverlay} />
                    </>
                  ) : (
                    <div className={styles.imagePlaceholder}>
                      <span className={styles.placeholderIcon}>&#9734;</span>
                    </div>
                  )}
                </div>

                {/* Right: meta info panel */}
                <div className={styles.slideMeta}>
                  <h2 className={styles.projectTitle}>{project.title}</h2>
                  <p className={styles.projectDesc}>{project.description}</p>
                  <div className={styles.techTags}>
                    {project.techStack
                      ?.split(',')
                      .filter(Boolean)
                      .map((tech) => (
                        <InkTag key={tech.trim()} variant="dark">
                          {tech.trim()}
                        </InkTag>
                      ))}
                  </div>
                  <div className={styles.links}>
                    {project.demoUrl && (
                      <a
                        className={styles.linkBtn}
                        href={project.demoUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                      >
                        Demo
                      </a>
                    )}
                    {project.repoUrl && (
                      <a
                        className={styles.linkBtn}
                        href={project.repoUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                      >
                        Code
                      </a>
                    )}
                  </div>
                </div>
              </section>
            ))}
          </div>

          {/* SnapNav dot navigation on the right */}
          <SnapNav containerRef={containerRef} count={filtered.length} />

          {/* Bottom prev/next navigation */}
          <div className={styles.bottomNav}>
            <button
              className={styles.navBtn}
              onClick={handlePrev}
              disabled={activeIndex === 0}
            >
              &larr; PREV
            </button>
            <div className={styles.navDivider} />
            <span className={styles.navCounter}>
              {activeIndex + 1}/{filtered.length}
            </span>
            <div className={styles.navDivider} />
            <button
              className={styles.navBtn}
              onClick={handleNext}
              disabled={activeIndex === filtered.length - 1}
            >
              NEXT &rarr;
            </button>
          </div>
        </>
      )}
    </div>
  );
};

export default ProjectShowcase;
