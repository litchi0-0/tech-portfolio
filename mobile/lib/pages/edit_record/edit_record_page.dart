import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../common/theme/app_colors.dart';
import '../../common/utils/validators.dart';
import '../../common/utils/snackbar_utils.dart';
import '../../common/utils/date_utils.dart' as app_date;
import '../../common/widgets/amount_input_field.dart';
import '../../models/transaction.dart';
import '../add_record/widgets/category_picker_sheet.dart';
import '../add_record/widgets/account_picker_sheet.dart';

class EditRecordPage extends StatefulWidget {
  final Transaction transaction;

  const EditRecordPage({super.key, required this.transaction});

  @override
  State<EditRecordPage> createState() => _EditRecordPageState();
}

class _EditRecordPageState extends State<EditRecordPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late String _type;
  int? _selectedCategoryId;
  int? _selectedAccountId;
  String _selectedCategoryName = '';
  String _selectedAccountName = '';
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _amountController = TextEditingController(text: tx.amount.toString());
    _noteController = TextEditingController(text: tx.note ?? '');
    _type = tx.type;
    _selectedCategoryId = tx.categoryId;
    _selectedAccountId = tx.accountId;
    _selectedCategoryName = tx.categoryName;
    _selectedAccountName = tx.accountName;
    _selectedDate = app_date.AppDateUtils.parseDateTime(tx.transactionDate) ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _selectedAccountId == null) return;

    final provider = context.read<TransactionProvider>();
    final success = await provider.updateTransaction(widget.transaction.id, {
      'accountId': _selectedAccountId,
      'categoryId': _selectedCategoryId,
      'amount': double.parse(_amountController.text.trim()),
      'type': _type,
      'note': _noteController.text.trim(),
      'transactionDate': app_date.AppDateUtils.toDateTimeString(_selectedDate),
    });

    if (!mounted) return;

    if (success) {
      SnackbarUtils.showSuccessSnackBar(context, '修改成功');
      Navigator.of(context).pop();
    } else {
      SnackbarUtils.showErrorSnackBar(context, provider.error ?? '修改失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('编辑记录'),
        backgroundColor: AppColors.background,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _submit,
              child: const Text('保存', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 收支切换
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  _buildTypeButton('支出', 'expense', AppColors.expense, AppColors.expenseGradient),
                  _buildTypeButton('收入', 'income', AppColors.income, AppColors.incomeGradient),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
              ),
              child: AmountInputField(
                controller: _amountController,
                validator: Validators.amount,
              ),
            ),
            const SizedBox(height: 12),

            _buildPickerTile(
              icon: Icons.category_outlined,
              label: '分类',
              value: _selectedCategoryName.isEmpty ? '请选择' : _selectedCategoryName,
              color: AppColors.primary,
              onTap: _pickCategory,
            ),
            const SizedBox(height: 10),
            _buildPickerTile(
              icon: Icons.account_balance_wallet_outlined,
              label: '账户',
              value: _selectedAccountName.isEmpty ? '请选择' : _selectedAccountName,
              color: const Color(0xFF34B87A),
              onTap: _pickAccount,
            ),
            const SizedBox(height: 10),
            _buildPickerTile(
              icon: Icons.calendar_today_outlined,
              label: '日期',
              value: app_date.AppDateUtils.toDisplayFull(_selectedDate),
              color: const Color(0xFFF5A623),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
              ),
              child: TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: '备注',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                maxLines: 3,
                minLines: 1,
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('保存修改'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String type, Color color, LinearGradient gradient) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _type = type;
            _selectedCategoryId = null;
            _selectedCategoryName = '';
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? gradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type == 'expense' ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isPlaceholder = value.contains('请选择');
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isPlaceholder ? AppColors.textHint : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickCategory() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: CategoryPickerSheet(type: _type),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedCategoryId = result['id'] as int;
        _selectedCategoryName = result['name'] as String;
      });
    }
  }

  Future<void> _pickAccount() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const AccountPickerSheet(),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedAccountId = result['id'] as int;
        _selectedAccountName = result['name'] as String;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year, picked.month, picked.day,
            time.hour, time.minute,
          );
        });
      } else {
        setState(() => _selectedDate = picked);
      }
    }
  }
}
