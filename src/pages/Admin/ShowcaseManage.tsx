import React, { useEffect, useState } from 'react';
import { Table, Button, Space, Modal, Form, Input, Select, message, Popconfirm, Tag } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons';
import { adminApi } from '../../api/admin';
import type { Showcase } from '../../types';

const { TextArea } = Input;

const ShowcaseManage: React.FC = () => {
  const [showcases, setShowcases] = useState<Showcase[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<Showcase | null>(null);
  const [form] = Form.useForm();

  const fetchData = async () => {
    setLoading(true);
    try {
      const res: any = await adminApi.getShowcases();
      setShowcases(res.data || []);
    } catch { message.error('获取数据失败'); }
    finally { setLoading(false); }
  };

  useEffect(() => { fetchData(); }, []);

  const handleSave = async () => {
    try {
      const values = await form.validateFields();
      if (editingItem) {
        await adminApi.updateShowcase(editingItem.id, values);
        message.success('更新成功');
      } else {
        await adminApi.createShowcase(values);
        message.success('创建成功');
      }
      setModalOpen(false);
      form.resetFields();
      setEditingItem(null);
      fetchData();
    } catch (err: any) {
      if (err.message) message.error(err.message);
    }
  };

  const handleDelete = async (id: number) => {
    try {
      await adminApi.deleteShowcase(id);
      message.success('删除成功');
      fetchData();
    } catch { message.error('删除失败'); }
  };

  const openEdit = (item: Showcase) => {
    setEditingItem(item);
    form.setFieldsValue(item);
    setModalOpen(true);
  };

  const openCreate = () => {
    setEditingItem(null);
    form.resetFields();
    setModalOpen(true);
  };

  const typeLabels: Record<string, string> = { bigscreen: '大屏展示', table: '表格展示', threejs: 'Three.js', demo: '演示' };
  const typeColors: Record<string, string> = { bigscreen: 'purple', table: 'blue', threejs: 'green', demo: 'orange' };

  const columns = [
    { title: 'ID', dataIndex: 'id', width: 60 },
    { title: '标题', dataIndex: 'title', width: 150 },
    { title: '类型', dataIndex: 'type', width: 120, render: (v: string) => <Tag color={typeColors[v] || 'default'}>{typeLabels[v] || v}</Tag> },
    { title: '描述', dataIndex: 'description', width: 250, ellipsis: true },
    { title: '演示地址', dataIndex: 'demoUrl', width: 150, ellipsis: true, render: (v: string) => v ? <a href={v} target="_blank" rel="noreferrer">{v}</a> : '-' },
    {
      title: '操作', width: 150, render: (_: any, record: Showcase) => (
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
        <h3>展示项管理</h3>
        <Button type="primary" icon={<PlusOutlined />} onClick={openCreate}>新增展示项</Button>
      </div>

      <Table columns={columns} dataSource={showcases} rowKey="id" loading={loading} pagination={{ pageSize: 10 }} />

      <Modal title={editingItem ? '编辑展示项' : '新增展示项'} open={modalOpen} onOk={handleSave} onCancel={() => { setModalOpen(false); form.resetFields(); setEditingItem(null); }} width={600}>
        <Form form={form} layout="vertical">
          <Form.Item name="title" label="标题" rules={[{ required: true, message: '请输入标题' }]}>
            <Input />
          </Form.Item>
          <Form.Item name="type" label="类型" rules={[{ required: true, message: '请选择类型' }]}>
            <Select options={[
              { label: '大屏展示', value: 'bigscreen' }, { label: '表格展示', value: 'table' },
              { label: 'Three.js', value: 'threejs' }, { label: '演示', value: 'demo' },
            ]} />
          </Form.Item>
          <Form.Item name="description" label="描述">
            <TextArea rows={3} />
          </Form.Item>
          <Form.Item name="thumbnail" label="缩略图URL">
            <Input />
          </Form.Item>
          <Form.Item name="content" label="内容">
            <TextArea rows={5} placeholder="JSON 或 HTML 内容" />
          </Form.Item>
          <Form.Item name="demoUrl" label="演示地址">
            <Input />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default ShowcaseManage;
