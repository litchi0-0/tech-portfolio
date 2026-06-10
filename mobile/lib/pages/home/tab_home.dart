import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../common/theme/app_colors.dart';
import '../../common/utils/money_utils.dart';
import '../../common/utils/date_utils.dart' as app_date;
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/empty_state_widget.dart';
import '../../common/widgets/error_widget.dart' as error_widget;
import '../../models/transaction.dart';
import '../../common/constants/app_constants.dart';
import '../transaction_detail/transaction_detail_page.dart';

class TabHome extends StatefulWidget {
  const TabHome({super.key});

  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('NuclearLedger'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedType = value == 'all' ? null : value);
              _refresh();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'all', child: Text('全部')),
              const PopupMenuItem(value: 'expense', child: Text('支出')),
              const PopupMenuItem(value: 'income', child: Text('收入')),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.filter_list, size: 20),
            ),
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.transactions.isEmpty) {
            return const LoadingWidget();
          }

          if (provider.error != null) {
            return error_widget.AppErrorWidget(
              message: provider.error!,
              onRetry: _refresh,
            );
          }

          if (provider.transactions.isEmpty) {
            return const EmptyStateWidget(
              icon: '📝',
              title: '暂无记录',
              subtitle: '点击下方 + 按钮开始记账',
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _refresh,
            child: Column(
              children: [
                _buildBalanceCard(provider),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: provider.transactions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TransactionCard(
                          transaction: provider.transactions[index],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TransactionDetailPage(
                                  transactionId: provider.transactions[index].id,
                                ),
                              ),
                            ).then((_) => _refresh());
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(TransactionProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.balanceCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '本月概况',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '收入',
                  provider.totalIncome,
                  Colors.white,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white24,
              ),
              Expanded(
                child: _buildStatItem(
                  '支出',
                  provider.totalExpense,
                  Colors.white70,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white24,
              ),
              Expanded(
                child: _buildStatItem(
                  '结余',
                  provider.balance,
                  Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '¥${MoneyUtils.formatCompact(amount)}',
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Future<void> _refresh() async {
    final now = DateTime.now();
    final startDate = app_date.AppDateUtils.toDateTimeString(
      DateTime(now.year, now.month, 1),
    );
    final endDate = app_date.AppDateUtils.toDateTimeString(
      DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );
    await context.read<TransactionProvider>().fetchTransactions(
          type: _selectedType,
          startDate: startDate,
          endDate: endDate,
        );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.isExpense;
    final emoji = AppConstants.categoryIcons[transaction.categoryName] ?? '💰';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              // 分类图标
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isExpense
                      ? AppColors.expenseLight
                      : AppColors.incomeLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              // 分类和备注
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.categoryName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      transaction.note ?? transaction.accountName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // 金额和日期
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    MoneyUtils.formatWithSign(transaction.amount, transaction.type),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isExpense ? AppColors.expense : AppColors.income,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatDate(transaction.transactionDate),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final dt = app_date.AppDateUtils.parseDateTime(dateStr);
    if (dt == null) return dateStr;
    return app_date.AppDateUtils.toDisplayDate(dt);
  }
}
