import React, { useEffect, useState } from 'react';
import { Table, Button, Space, Modal, Form, Input, Select, InputNumber, message, Popconfirm, Tag, Slider } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons';
import { adminApi } from '../../api/admin';
import type { TechStack } from '../../types';

const { TextArea } = Input;

const TechStackManage: React.FC = () => {
  const [techStacks, setTechStacks] = useState<TechStack[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<TechStack | null>(null);
  const [form] = Form.useForm();

  const fetchData = async () => {
    setLoading(true);
    try {
      const res: any = await adminApi.getTechStacks();
      setTechStacks(res.data || []);
    } catch { message.error('获取数据失败'); }
    finally { setLoading(false); }
  };

  useEffect(() => { fetchData(); }, []);

  const handleSave = async () => {
    try {
      const values = await form.validateFields();
      if (editingItem) {
        await adminApi.updateTechStack(editingItem.id, values);
        message.success('更新成功');
      } else {
        await adminApi.createTechStack(values);
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
      await adminApi.deleteTechStack(id);
      message.success('删除成功');
      fetchData();
    } catch { message.error('删除失败'); }
  };

  const openEdit = (item: TechStack) => {
    setEditingItem(item);
    form.setFieldsValue(item);
    setModalOpen(true);
  };

  const openCreate = () => {
    setEditingItem(null);
    form.resetFields();
    setModalOpen(true);
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', width: 60 },
    { title: '名称', dataIndex: 'name', width: 120 },
    { title: '分类', dataIndex: 'category', width: 100, render: (v: string) => v ? <Tag color="blue">{v}</Tag> : '-' },
    { title: '熟练度', dataIndex: 'proficiency', width: 150, render: (v: number) => <Slider value={v} disabled style={{ width: 120 }} /> },
    { title: '排序', dataIndex: 'sortOrder', width: 80 },
    { title: '状态', dataIndex: 'status', width: 80, render: (v: number) => <Tag color={v === 1 ? 'green' : 'red'}>{v === 1 ? '显示' : '隐藏'}</Tag> },
    {
      title: '操作', width: 150, render: (_: any, record: TechStack) => (
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
        <h3>技术栈管理</h3>
        <Button type="primary" icon={<PlusOutlined />} onClick={openCreate}>新增技术栈</Button>
      </div>

      <Table columns={columns} dataSource={techStacks} rowKey="id" loading={loading} pagination={{ pageSize: 10 }} />

      <Modal title={editingItem ? '编辑技术栈' : '新增技术栈'} open={modalOpen} onOk={handleSave} onCancel={() => { setModalOpen(false); form.resetFields(); setEditingItem(null); }} width={500}>
        <Form form={form} layout="vertical">
          <Form.Item name="name" label="名称" rules={[{ required: true, message: '请输入名称' }]}>
            <Input />
          </Form.Item>
          <Form.Item name="category" label="分类">
            <Select allowClear options={[
              { label: '前端', value: 'frontend' }, { label: '后端', value: 'backend' },
              { label: '数据库', value: 'database' }, { label: 'DevOps', value: 'devops' },
              { label: '其他', value: 'other' },
            ]} />
          </Form.Item>
          <Form.Item name="icon" label="图标URL">
            <Input />
          </Form.Item>
          <Form.Item name="proficiency" label="熟练度" initialValue={50}>
            <Slider min={0} max={100} />
          </Form.Item>
          <Form.Item name="description" label="描述">
            <TextArea rows={3} />
          </Form.Item>
          <Form.Item name="sortOrder" label="排序" initialValue={0}>
            <InputNumber min={0} />
          </Form.Item>
          {editingItem && (
            <Form.Item name="status" label="状态">
              <Select options={[{ label: '显示', value: 1 }, { label: '隐藏', value: 0 }]} />
            </Form.Item>
          )}
        </Form>
      </Modal>
    </div>
  );
};

export default TechStackManage;
