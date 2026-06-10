import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/utils/money_utils.dart';
import '../../../common/widgets/empty_state_widget.dart';
import '../../../models/budget.dart';
import '../../budget_form/budget_form_page.dart';

class BudgetOverview extends StatelessWidget {
  const BudgetOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.budgets.isEmpty) {
          return EmptyStateWidget(
            icon: '💰',
            title: '暂无预算',
            subtitle: '点击下方按钮添加月度预算',
            action: ElevatedButton.icon(
              onPressed: () => _navigateToForm(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('添加预算'),
            ),
          );
        }

        final txProvider = context.watch<TransactionProvider>();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 总预算卡片
            if (provider.totalBudget != null)
              _buildTotalBudgetCard(provider.totalBudget!, txProvider.totalExpense),
            const SizedBox(height: 16),

            // 分类预算标题
            Row(
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
                const Text(
                  '分类预算',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...provider.categoryBudgets.map(
              (b) => _BudgetCard(
                budget: b,
                spent: _getSpentForCategory(txProvider, b.categoryId),
                onEdit: () => _navigateToForm(context, budget: b),
                onDelete: () => _deleteBudget(context, b),
              ),
            ),

            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _navigateToForm(context),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('添加预算'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  double _getSpentForCategory(TransactionProvider txProvider, int? categoryId) {
    if (categoryId == null) return 0;
    return txProvider.transactions
        .where((t) => t.isExpense && t.categoryId == categoryId)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Widget _buildTotalBudgetCard(Budget budget, double spent) {
    final percentage = budget.amount > 0 ? spent / budget.amount : 0.0;
    final isOver = percentage > 1;
    final remaining = budget.amount - spent;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isOver
            ? LinearGradient(
                colors: [AppColors.error.withValues(alpha: 0.9), AppColors.expense],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppColors.balanceCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isOver ? AppColors.error : AppColors.primary).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
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
                  '本月总预算',
                  style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
              const Spacer(),
              if (isOver)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '已超支',
                    style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '¥${MoneyUtils.format(budget.amount)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage.clamp(0, 1),
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已支出 ¥${MoneyUtils.formatCompact(spent)}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Text(
                isOver
                    ? '超支 ¥${MoneyUtils.formatCompact(-remaining)}'
                    : '剩余 ¥${MoneyUtils.formatCompact(remaining)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToForm(BuildContext context, {Budget? budget}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BudgetFormPage(budget: budget),
      ),
    );
  }

  Future<void> _deleteBudget(BuildContext context, Budget budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('删除预算'),
        content: Text('确定要删除「${budget.categoryName ?? '总预算'}」的预算吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<BudgetProvider>().deleteBudget(budget.id);
    }
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.budget,
    required this.spent,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = budget.amount > 0 ? spent / budget.amount : 0.0;
    final isOver = percentage > 1;
    final progressColor = isOver
        ? AppColors.error
        : percentage > 0.8
            ? AppColors.warning
            : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        budget.categoryName ?? '总预算',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      '¥${MoneyUtils.formatCompact(spent)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isOver ? AppColors.error : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      ' / ¥${MoneyUtils.formatCompact(budget.amount)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      style: IconButton.styleFrom(
                        foregroundColor: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage.clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(percentage * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: progressColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isOver
                          ? '超支 ¥${MoneyUtils.formatCompact(spent - budget.amount)}'
                          : '剩余 ¥${MoneyUtils.formatCompact(budget.amount - spent)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isOver ? AppColors.error : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
