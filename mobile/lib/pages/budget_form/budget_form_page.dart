import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../common/theme/app_colors.dart';
import '../../common/utils/validators.dart';
import '../../common/utils/snackbar_utils.dart';
import '../../common/utils/date_utils.dart' as app_date;
import '../../models/budget.dart';

class BudgetFormPage extends StatefulWidget {
  final Budget? budget;

  const BudgetFormPage({super.key, this.budget});

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  int? _selectedCategoryId;
  String _selectedCategoryName = '';
  late String _selectedMonth;

  bool get isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.budget?.month ?? app_date.AppDateUtils.currentMonth();
    if (widget.budget != null) {
      _amountController.text = widget.budget!.amount.toString();
      _selectedCategoryId = widget.budget!.categoryId;
      _selectedCategoryName = widget.budget!.categoryName ?? '总预算';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<BudgetProvider>();
    final body = {
      'amount': double.parse(_amountController.text.trim()),
      'month': _selectedMonth,
      if (_selectedCategoryId != null) 'categoryId': _selectedCategoryId,
    };

    final success = isEditing
        ? await provider.updateBudget(widget.budget!.id, body)
        : await provider.createBudget(body);

    if (!mounted) return;

    if (success) {
      SnackbarUtils.showSuccessSnackBar(context, isEditing ? '修改成功' : '添加成功');
      Navigator.of(context).pop();
    } else {
      SnackbarUtils.showErrorSnackBar(context, provider.error ?? '操作失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? '编辑预算' : '添加预算'),
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
            _buildPickerTile(
              icon: Icons.calendar_month_outlined,
              label: '月份',
              value: _selectedMonth,
              color: const Color(0xFF4A90D9),
              onTap: _pickMonth,
            ),
            const SizedBox(height: 12),
            _buildPickerTile(
              icon: Icons.category_outlined,
              label: '分类（不选则为总预算）',
              value: _selectedCategoryName.isEmpty ? '总预算' : _selectedCategoryName,
              color: const Color(0xFF9B59B6),
              onTap: _pickCategory,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
              ),
              child: TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.amount,
                decoration: const InputDecoration(
                  labelText: '预算金额',
                  prefixText: '¥ ',
                  prefixStyle: TextStyle(fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -1),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEditing ? '保存修改' : '添加预算'),
            ),
          ],
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
                    Text(
                      label,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
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

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse('$_selectedMonth-01') ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = app_date.AppDateUtils.toMonthString(picked);
      });
    }
  }

  Future<void> _pickCategory() async {
    final categories = context.read<CategoryProvider>().expenseCategories;
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              '选择分类',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.attach_money_rounded, color: AppColors.primary, size: 22),
              ),
              title: const Text('总预算（不限分类）'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () => Navigator.of(context).pop({'id': null, 'name': '总预算'}),
            ),
            const Divider(height: 8),
            ...categories.map((c) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.expenseLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.category_rounded, color: AppColors.expense, size: 22),
                  ),
                  title: Text(c.name),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () => Navigator.of(context).pop({'id': c.id, 'name': c.name}),
                )),
          ],
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedCategoryId = result['id'] as int?;
        _selectedCategoryName = result['name'] as String;
      });
    }
  }
}
