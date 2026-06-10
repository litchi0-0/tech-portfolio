import React, { useEffect, useState } from 'react';
import { Table, Button, Space, Modal, Form, Input, Select, InputNumber, Upload, message, Popconfirm, Tag, Image } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined, UploadOutlined } from '@ant-design/icons';
import { adminApi } from '../../api/admin';
import type { Project } from '../../types';

const { TextArea } = Input;

const ProjectManage: React.FC = () => {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editingProject, setEditingProject] = useState<Project | null>(null);
  const [form] = Form.useForm();

  const fetchProjects = async () => {
    setLoading(true);
    try {
      const res: any = await adminApi.getProjects();
      setProjects(res.data || []);
    } catch { message.error('获取项目失败'); }
    finally { setLoading(false); }
  };

  useEffect(() => { fetchProjects(); }, []);

  const handleSave = async () => {
    try {
      const values = await form.validateFields();
      if (editingProject) {
        await adminApi.updateProject(editingProject.id, values);
        message.success('更新成功');
      } else {
        await adminApi.createProject(values);
        message.success('创建成功');
      }
      setModalOpen(false);
      form.resetFields();
      setEditingProject(null);
      fetchProjects();
    } catch (err: any) {
      if (err.message) message.error(err.message);
    }
  };

  const handleDelete = async (id: number) => {
    try {
      await adminApi.deleteProject(id);
      message.success('删除成功');
      fetchProjects();
    } catch { message.error('删除失败'); }
  };

  const openEdit = (project: Project) => {
    setEditingProject(project);
    form.setFieldsValue(project);
    setModalOpen(true);
  };

  const openCreate = () => {
    setEditingProject(null);
    form.resetFields();
    setModalOpen(true);
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', width: 60 },
    { title: '标题', dataIndex: 'title', width: 150 },
    { title: '分类', dataIndex: 'category', width: 100, render: (v: string) => v ? <Tag color="blue">{v}</Tag> : '-' },
    { title: '技术栈', dataIndex: 'techStack', width: 200, render: (v: string) => v?.split(',').map((t: string) => <Tag key={t}>{t.trim()}</Tag>) },
    { title: '封面', dataIndex: 'coverImage', width: 100, render: (v: string) => v ? <Image src={v} width={60} height={40} style={{ objectFit: 'cover' }} /> : '-' },
    { title: '排序', dataIndex: 'sortOrder', width: 80 },
    { title: '状态', dataIndex: 'status', width: 80, render: (v: number) => <Tag color={v === 1 ? 'green' : 'red'}>{v === 1 ? '显示' : '隐藏'}</Tag> },
    {
      title: '操作', width: 150, render: (_: any, record: Project) => (
        <Space>
          <Button type="link" size="small" icon={<EditOutlined />} onClick={() => openEdit(record)}>编辑</Button>
          <Popconfirm title="确定删除?" onConfirm={() => handleDelete(record.id)}>
            <Button type="link" size="small" danger icon={<DeleteOutlined />}>删除</Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 16 }}>
        <h3>项目管理</h3>
        <Button type="primary" icon={<PlusOutlined />} onClick={openCreate}>新增项目</Button>
      </div>

      <Table columns={columns} dataSource={projects} rowKey="id" loading={loading} pagination={{ pageSize: 10 }} />

      <Modal title={editingProject ? '编辑项目' : '新增项目'} open={modalOpen} onOk={handleSave} onCancel={() => { setModalOpen(false); form.resetFields(); setEditingProject(null); }} width={600}>
        <Form form={form} layout="vertical">
          <Form.Item name="title" label="标题" rules={[{ required: true, message: '请输入标题' }]}>
            <Input />
          </Form.Item>
          <Form.Item name="description" label="描述">
            <TextArea rows={3} />
          </Form.Item>
          <Form.Item name="category" label="分类">
            <Select allowClear options={[
              { label: '全栈', value: 'fullstack' }, { label: '前端', value: 'frontend' },
              { label: '后端', value: 'backend' }, { label: '移动端', value: 'mobile' },
            ]} />
          </Form.Item>
          <Form.Item name="techStack" label="技术栈（逗号分隔）">
            <Input placeholder="React, TypeScript, Spring Boot" />
          </Form.Item>
          <Form.Item name="coverImage" label="封面图URL">
            <Input />
          </Form.Item>
          <Form.Item name="demoUrl" label="演示地址">
            <Input />
          </Form.Item>
          <Form.Item name="repoUrl" label="仓库地址">
            <Input />
          </Form.Item>
          <Form.Item name="sortOrder" label="排序" initialValue={0}>
            <InputNumber min={0} />
          </Form.Item>
          {editingProject && (
            <Form.Item name="status" label="状态">
              <Select options={[{ label: '显示', value: 1 }, { label: '隐藏', value: 0 }]} />
            </Form.Item>
          )}
        </Form>
      </Modal>
    </div>
  );
};

export default ProjectManage;
