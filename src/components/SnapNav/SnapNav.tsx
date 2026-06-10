import React, { useEffect, useState } from 'react';
import styles from './SnapNav.module.css';

interface SnapNavProps {
  containerRef: React.RefObject<HTMLElement | null>;
  count: number;
}

const SnapNav: React.FC<SnapNavProps> = ({ containerRef, count }) => {
  const [activeIndex, setActiveIndex] = useState(0);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const sections = container.querySelectorAll('section');
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const idx = Array.from(sections).indexOf(entry.target);
            if (idx >= 0) setActiveIndex(idx);
          }
        });
      },
      { root: container, threshold: 0.5 }
    );

    sections.forEach((s) => observer.observe(s));
    return () => observer.disconnect();
  }, [containerRef]);

  const handleClick = (index: number) => {
    const container = containerRef.current;
    if (!container) return;
    const sections = container.querySelectorAll('section');
    sections[index]?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <nav className={styles.nav}>
      {Array.from({ length: count }, (_, i) => (
        <button
          key={i}
          className={`${styles.dot} ${i === activeIndex ? styles.dotActive : ''}`}
          onClick={() => handleClick(i)}
          aria-label={`Section ${i + 1}`}
        />
      ))}
    </nav>
  );
};

export default SnapNav;
