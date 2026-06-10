import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/budget_provider.dart';
import '../../common/theme/app_colors.dart';
import '../../common/utils/money_utils.dart';
import '../../common/utils/date_utils.dart' as app_date;
import 'widgets/pie_chart_section.dart';
import 'widgets/budget_overview.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final startDate = app_date.AppDateUtils.toDateTimeString(
      DateTime(_selectedMonth.year, _selectedMonth.month, 1),
    );
    final endDate = app_date.AppDateUtils.toDateTimeString(
      DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59),
    );
    await Future.wait([
      context.read<TransactionProvider>().fetchTransactions(
            startDate: startDate,
            endDate: endDate,
          ),
      context.read<CategoryProvider>().fetchCategories(),
      context.read<BudgetProvider>().fetchBudgets(
            month: app_date.AppDateUtils.toMonthString(_selectedMonth),
          ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '收支分析'),
            Tab(text: '预算管理'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAnalysisTab(),
                const BudgetOverview(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    final monthStr = '${_selectedMonth.year}年${_selectedMonth.month}月';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 24),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
              });
              _loadData();
            },
            style: IconButton.styleFrom(
              backgroundColor: AppColors.background,
              minimumSize: const Size(36, 36),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            monthStr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 24),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
              });
              _loadData();
            },
            style: IconButton.styleFrom(
              backgroundColor: AppColors.background,
              minimumSize: const Size(36, 36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.transactions.isEmpty) {
          return const Center(
            child: Text('本月暂无记录', style: TextStyle(color: AppColors.textSecondary)),
          );
        }

        final expenses = provider.transactions.where((t) => t.isExpense).toList();
        final incomes = provider.transactions.where((t) => t.isIncome).toList();

        final Map<String, double> expenseByCategory = {};
        for (final t in expenses) {
          expenseByCategory[t.categoryName] =
              (expenseByCategory[t.categoryName] ?? 0) + t.amount;
        }

        final Map<String, double> incomeByCategory = {};
        for (final t in incomes) {
          incomeByCategory[t.categoryName] =
              (incomeByCategory[t.categoryName] ?? 0) + t.amount;
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 总览卡片
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      '支出',
                      provider.totalExpense,
                      AppColors.expense,
                      AppColors.expenseGradient,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: AppColors.divider,
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      '收入',
                      provider.totalIncome,
                      AppColors.income,
                      AppColors.incomeGradient,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 支出饼图
            if (expenseByCategory.isNotEmpty) ...[
              _sectionTitle('支出构成'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
                ),
                child: PieChartSection(data: expenseByCategory),
              ),
              const SizedBox(height: 24),
            ],

            // 收入饼图
            if (incomeByCategory.isNotEmpty) ...[
              _sectionTitle('收入构成'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
                ),
                child: PieChartSection(data: incomeByCategory),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color, LinearGradient gradient) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            label == '支出' ? Icons.trending_down_rounded : Icons.trending_up_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(
          '¥${MoneyUtils.formatCompact(amount)}',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
