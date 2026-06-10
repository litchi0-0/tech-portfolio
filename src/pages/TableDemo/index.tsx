import React, { useState, useMemo } from 'react';
import InkTag from '../../components/InkTag/InkTag';
import styles from './TableDemo.module.css';

interface TableDataRow {
  id: number;
  name: string;
  department: string;
  role: string;
  status: string;
  joinDate: string;
  salary: number;
  performance: number;
}

const mockData: TableDataRow[] = [
  { id: 1, name: '张三', department: '技术部', role: '前端工程师', status: '在职', joinDate: '2023-03-15', salary: 25000, performance: 95 },
  { id: 2, name: '李四', department: '技术部', role: '后端工程师', status: '在职', joinDate: '2023-05-20', salary: 28000, performance: 88 },
  { id: 3, name: '王五', department: '产品部', role: '产品经理', status: '在职', joinDate: '2022-11-01', salary: 30000, performance: 92 },
  { id: 4, name: '赵六', department: '设计部', role: 'UI设计师', status: '离职', joinDate: '2023-01-10', salary: 22000, performance: 85 },
  { id: 5, name: '孙七', department: '技术部', role: '全栈工程师', status: '在职', joinDate: '2022-08-15', salary: 32000, performance: 97 },
  { id: 6, name: '周八', department: '运维部', role: 'DevOps工程师', status: '在职', joinDate: '2023-07-01', salary: 26000, performance: 90 },
  { id: 7, name: '吴九', department: '技术部', role: '数据工程师', status: '在职', joinDate: '2024-01-15', salary: 27000, performance: 86 },
  { id: 8, name: '郑十', department: '产品部', role: '产品助理', status: '试用期', joinDate: '2024-06-01', salary: 15000, performance: 78 },
];

const PAGE_SIZE = 5;

const TableDemo: React.FC = () => {
  const [searchText, setSearchText] = useState('');
  const [currentPage, setCurrentPage] = useState(1);

  const filteredData = useMemo(() => {
    if (!searchText) return mockData;
    return mockData.filter(
      d => d.name.includes(searchText) || d.department.includes(searchText)
    );
  }, [searchText]);

  const totalPages = Math.max(1, Math.ceil(filteredData.length / PAGE_SIZE));
  const safeCurrentPage = Math.min(currentPage, totalPages);
  const paginatedData = filteredData.slice(
    (safeCurrentPage - 1) * PAGE_SIZE,
    safeCurrentPage * PAGE_SIZE
  );

  const getPerfClass = (v: number) => {
    if (v >= 90) return styles.perfHigh;
    if (v >= 80) return styles.perfMid;
    return styles.perfLow;
  };

  const handleSearch = (value: string) => {
    setSearchText(value);
    setCurrentPage(1);
  };

  return (
    <div className={styles.page}>
      <div className={styles.header}>
        <div className={styles.label}>TABLE DEMO</div>
        <h1 className={styles.title}>表格展示</h1>
      </div>

      <div className={styles.toolbar}>
        <input
          className={styles.searchInput}
          placeholder="搜索姓名 / 部门"
          value={searchText}
          onChange={e => handleSearch(e.target.value)}
        />
        {searchText && (
          <button className={styles.resetBtn} onClick={() => handleSearch('')}>
            重置
          </button>
        )}
      </div>

      <div className={styles.tableWrap}>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>姓名</th>
              <th>部门</th>
              <th>职位</th>
              <th>状态</th>
              <th>入职日期</th>
              <th>薪资</th>
              <th>绩效分</th>
            </tr>
          </thead>
          <tbody>
            {paginatedData.map(row => (
              <tr key={row.id}>
                <td>{row.id}</td>
                <td>{row.name}</td>
                <td>{row.department}</td>
                <td>{row.role}</td>
                <td>
                  <InkTag variant={row.status === '在职' ? 'accent' : 'default'}>
                    {row.status}
                  </InkTag>
                </td>
                <td>{row.joinDate}</td>
                <td>{`¥${row.salary.toLocaleString()}`}</td>
                <td className={getPerfClass(row.performance)}>{row.performance}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {totalPages > 1 && (
        <div className={styles.pagination}>
          <button
            className={styles.arrowBtn}
            disabled={safeCurrentPage <= 1}
            onClick={() => setCurrentPage(p => p - 1)}
          >
            &larr;
          </button>
          {Array.from({ length: totalPages }, (_, i) => i + 1).map(page => (
            <button
              key={page}
              className={`${styles.pageBtn} ${page === safeCurrentPage ? styles.pageBtnActive : ''}`}
              onClick={() => setCurrentPage(page)}
            >
              {page}
            </button>
          ))}
          <button
            className={styles.arrowBtn}
            disabled={safeCurrentPage >= totalPages}
            onClick={() => setCurrentPage(p => p + 1)}
          >
            &rarr;
          </button>
        </div>
      )}
    </div>
  );
};

export default TableDemo;
