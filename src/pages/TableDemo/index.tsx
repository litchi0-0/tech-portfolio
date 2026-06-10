import React, { useEffect, useState } from 'react';
import { Table, Card, Tag, Space, Button, Input, Typography, Spin } from 'antd';
import { SearchOutlined, ReloadOutlined } from '@ant-design/icons';
import { portfolioApi } from '../../api/portfolio';
import type { Showcase } from '../../types';

const { Title } = Typography;

interface TableDataRow {
  key: string;
  id: number;
  name: string;
  department: string;
  role: string;
  status: string;
  joinDate: string;
  salary: number;
  performance: number;
}

const TableDemo: React.FC = () => {
  const [showcases, setShowcases] = useState<Showcase[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchText, setSearchText] = useState('');

  useEffect(() => {
    portfolioApi.getShowcases('table').then((res: any) => setShowcases(res.data || [])).catch(() => {}).finally(() => setLoading(false));
  }, []);

  // Hardcoded demo data
  const mockData: TableDataRow[] = [
    { key: '1', id: 1, name: '张三', department: '技术部', role: '前端工程师', status: '在职', joinDate: '2023-03-15', salary: 25000, performance: 95 },
    { key: '2', id: 2, name: '李四', department: '技术部', role: '后端工程师', status: '在职', joinDate: '2023-05-20', salary: 28000, performance: 88 },
    { key: '3', id: 3, name: '王五', department: '产品部', role: '产品经理', status: '在职', joinDate: '2022-11-01', salary: 30000, performance: 92 },
    { key: '4', id: 4, name: '赵六', department: '设计部', role: 'UI设计师', status: '离职', joinDate: '2023-01-10', salary: 22000, performance: 85 },
    { key: '5', id: 5, name: '孙七', department: '技术部', role: '全栈工程师', status: '在职', joinDate: '2022-08-15', salary: 32000, performance: 97 },
    { key: '6', id: 6, name: '周八', department: '运维部', role: 'DevOps工程师', status: '在职', joinDate: '2023-07-01', salary: 26000, performance: 90 },
    { key: '7', id: 7, name: '吴九', department: '技术部', role: '数据工程师', status: '在职', joinDate: '2024-01-15', salary: 27000, performance: 86 },
    { key: '8', id: 8, name: '郑十', department: '产品部', role: '产品助理', status: '试用期', joinDate: '2024-06-01', salary: 15000, performance: 78 },
  ];

  const filteredData = mockData.filter(d => !searchText || d.name.includes(searchText) || d.department.includes(searchText));

  const columns = [
    { title: 'ID', dataIndex: 'id', sorter: (a: TableDataRow, b: TableDataRow) => a.id - b.id, width: 60 },
    { title: '姓名', dataIndex: 'name' },
    { title: '部门', dataIndex: 'department', filters: Array.from(new Set(mockData.map(d => d.department))).map(d => ({ text: d, value: d })), onFilter: (value: any, record: TableDataRow) => record.department === value },
    { title: '职位', dataIndex: 'role' },
    { title: '状态', dataIndex: 'status', render: (status: string) => {
      const color = status === '在职' ? 'green' : status === '离职' ? 'red' : 'orange';
      return <Tag color={color}>{status}</Tag>;
    }},
    { title: '入职日期', dataIndex: 'joinDate', sorter: (a: TableDataRow, b: TableDataRow) => a.joinDate.localeCompare(b.joinDate) },
    { title: '薪资', dataIndex: 'salary', sorter: (a: TableDataRow, b: TableDataRow) => a.salary - b.salary, render: (v: number) => `¥${v.toLocaleString()}` },
    { title: '绩效分', dataIndex: 'performance', sorter: (a: TableDataRow, b: TableDataRow) => a.performance - b.performance, render: (v: number) => {
      const color = v >= 90 ? '#52c41a' : v >= 80 ? '#faad14' : '#ff4d4f';
      return <span style={{ color, fontWeight: 'bold' }}>{v}</span>;
    }},
    { title: '操作', render: () => <Space><Button size="small" type="link">编辑</Button><Button size="small" type="link" danger>删除</Button></Space> },
  ];

  return (
    <div style={{ maxWidth: 1200, margin: '0 auto', padding: '40px 24px' }}>
      <Title level={2}>{showcases.length > 0 ? showcases[0].title : '表格展示'}</Title>

      <Card>
        <Space style={{ marginBottom: 16 }}>
          <Input placeholder="搜索姓名/部门" prefix={<SearchOutlined />} value={searchText} onChange={e => setSearchText(e.target.value)} style={{ width: 250 }} />
          <Button icon={<ReloadOutlined />} onClick={() => setSearchText('')}>重置</Button>
        </Space>
        <Table columns={columns} dataSource={filteredData} pagination={{ pageSize: 5, showTotal: (total) => `共 ${total} 条` }} size="middle" bordered />
      </Card>
    </div>
  );
};

export default TableDemo;
