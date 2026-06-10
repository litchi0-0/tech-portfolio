import client from './client';
import type { DashboardStats, Project, TechStack, Showcase, ApiResponse } from '../types';

export const portfolioApi = {
  getDashboard: () => client.get<ApiResponse<DashboardStats>>('/portfolio/dashboard'),
  getProjects: () => client.get<ApiResponse<Project[]>>('/portfolio/projects'),
  getTechStacks: () => client.get<ApiResponse<TechStack[]>>('/portfolio/tech-stacks'),
  getShowcases: (type?: string) => client.get<ApiResponse<Showcase[]>>('/portfolio/showcases', { params: { type } }),
};
