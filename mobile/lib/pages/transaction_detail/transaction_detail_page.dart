import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../common/theme/app_colors.dart';
import '../../common/utils/money_utils.dart';
import '../../common/utils/date_utils.dart' as app_date;
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/confirm_dialog.dart';
import '../../common/utils/snackbar_utils.dart';
import '../../models/transaction.dart';
import '../edit_record/edit_record_page.dart';

class TransactionDetailPage extends StatefulWidget {
  final int transactionId;

  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  Transaction? _transaction;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    try {
      final provider = context.read<TransactionProvider>();
      final tx = await provider.findTransactionById(widget.transactionId);
      setState(() {
        _transaction = tx;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('账单详情'),
        backgroundColor: AppColors.background,
        actions: [
          if (_transaction != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (_) => EditRecordPage(transaction: _transaction!),
                  ),
                )
                    .then((_) {
                  _loadTransaction();
                  context.read<TransactionProvider>().fetchTransactions();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _transaction == null
              ? const Center(child: Text('未找到该记录'))
              : _buildDetail(),
    );
  }

  Widget _buildDetail() {
    final tx = _transaction!;
    final isExpense = tx.isExpense;
    final gradient = isExpense ? AppColors.expenseGradient : AppColors.incomeGradient;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 金额卡片
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isExpense ? AppColors.expense : AppColors.income).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isExpense ? '支出' : '收入',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '¥${MoneyUtils.format(tx.amount)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 详情信息卡片
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
          ),
          child: Column(
            children: [
              _buildInfoRow(Icons.category_outlined, '分类', tx.categoryName,
                  showTopBorder: false),
              _buildInfoRow(Icons.account_balance_wallet_outlined, '账户', tx.accountName),
              _buildInfoRow(
                Icons.calendar_today_outlined,
                '时间',
                app_date.AppDateUtils.toDisplayFull(
                  app_date.AppDateUtils.parseDateTime(tx.transactionDate) ?? DateTime.now(),
                ),
              ),
              if (tx.note != null && tx.note!.isNotEmpty)
                _buildInfoRow(Icons.edit_note_rounded, '备注', tx.note!,
                    showBottomBorder: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool showTopBorder = true,
    bool showBottomBorder = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          top: showTopBorder
              ? BorderSide(color: AppColors.divider.withValues(alpha: 0.6))
              : BorderSide.none,
          bottom: showBottomBorder
              ? BorderSide(color: AppColors.divider.withValues(alpha: 0.6))
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: '删除确认',
      content: '确定要删除这条记录吗？删除后不可恢复。',
      confirmText: '删除',
      isDangerous: true,
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<TransactionProvider>();
    final success = await provider.deleteTransaction(widget.transactionId);
    if (!mounted) return;

    if (success) {
      SnackbarUtils.showSuccessSnackBar(context, '删除成功');
      Navigator.of(context).pop();
    } else {
      SnackbarUtils.showErrorSnackBar(context, provider.error ?? '删除失败');
    }
  }
}
