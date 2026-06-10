export interface Project {
  id: number;
  title: string;
  description: string;
  category: string;
  techStack: string;
  coverImage: string;
  demoUrl: string;
  repoUrl: string;
  sortOrder: number;
  status: number;
  createdAt: string;
  updatedAt: string;
}

export interface TechStack {
  id: number;
  name: string;
  category: string;
  icon: string;
  proficiency: number;
  description: string;
  sortOrder: number;
  status: number;
  createdAt: string;
  updatedAt: string;
}

export interface Showcase {
  id: number;
  title: string;
  type: 'bigscreen' | 'table' | 'threejs' | 'demo';
  description: string;
  thumbnail: string;
  content: string;
  demoUrl: string;
  createdAt: string;
  updatedAt: string;
}

export interface DashboardStats {
  projectCount: number;
  techStackCount: number;
  showcaseCount: number;
}

export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

export interface LoginRequest {
  username: string;
  password: string;
  appKey: string;
}

export interface LoginResponse {
  token: string;
  user: {
    id: number;
    username: string;
    nickname: string;
  };
}
