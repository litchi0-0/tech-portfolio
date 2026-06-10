import client from './client';
import type { Project, TechStack, Showcase, ApiResponse } from '../types';

export const adminApi = {
  // Projects
  getProjects: () => client.get<ApiResponse<Project[]>>('/admin/portfolio/projects'),
  createProject: (data: Partial<Project>) => client.post<ApiResponse<Project>>('/admin/portfolio/projects', data),
  updateProject: (id: number, data: Partial<Project>) => client.put<ApiResponse<Project>>(`/admin/portfolio/projects/${id}`, data),
  deleteProject: (id: number) => client.delete<ApiResponse<boolean>>(`/admin/portfolio/projects/${id}`),

  // Tech Stacks
  getTechStacks: () => client.get<ApiResponse<TechStack[]>>('/admin/portfolio/tech-stacks'),
  createTechStack: (data: Partial<TechStack>) => client.post<ApiResponse<TechStack>>('/admin/portfolio/tech-stacks', data),
  updateTechStack: (id: number, data: Partial<TechStack>) => client.put<ApiResponse<TechStack>>(`/admin/portfolio/tech-stacks/${id}`, data),
  deleteTechStack: (id: number) => client.delete<ApiResponse<boolean>>(`/admin/portfolio/tech-stacks/${id}`),

  // Showcases
  getShowcases: () => client.get<ApiResponse<Showcase[]>>('/admin/portfolio/showcases'),
  createShowcase: (data: Partial<Showcase>) => client.post<ApiResponse<Showcase>>('/admin/portfolio/showcases', data),
  updateShowcase: (id: number, data: Partial<Showcase>) => client.put<ApiResponse<Showcase>>(`/admin/portfolio/showcases/${id}`, data),
  deleteShowcase: (id: number) => client.delete<ApiResponse<boolean>>(`/admin/portfolio/showcases/${id}`),

  // File upload
  uploadFile: (file: File) => {
    const formData = new FormData();
    formData.append('file', file);
    return client.post('/admin/portfolio/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },
};
