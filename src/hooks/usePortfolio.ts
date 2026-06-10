import { useState, useEffect } from 'react';
import { portfolioApi } from '../api/portfolio';
import type { Project, TechStack, Showcase, DashboardStats } from '../types';

export function useProjects() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    portfolioApi.getProjects()
      .then((res: any) => setProjects(res.data || []))
      .catch(() => setProjects([]))
      .finally(() => setLoading(false));
  }, []);
  return { projects, loading };
}

export function useTechStacks() {
  const [techStacks, setTechStacks] = useState<TechStack[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    portfolioApi.getTechStacks()
      .then((res: any) => setTechStacks(res.data || []))
      .catch(() => setTechStacks([]))
      .finally(() => setLoading(false));
  }, []);
  return { techStacks, loading };
}

export function useShowcases(type?: string) {
  const [showcases, setShowcases] = useState<Showcase[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    portfolioApi.getShowcases(type)
      .then((res: any) => setShowcases(res.data || []))
      .catch(() => setShowcases([]))
      .finally(() => setLoading(false));
  }, [type]);
  return { showcases, loading };
}

export function useDashboardStats() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    portfolioApi.getDashboard()
      .then((res: any) => setStats(res.data))
      .catch(() => setStats(null))
      .finally(() => setLoading(false));
  }, []);
  return { stats, loading };
}
