import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../common/theme/app_colors.dart';
import '../../common/utils/validators.dart';
import '../../common/utils/snackbar_utils.dart';
import '../../models/category.dart';

class CategoryFormPage extends StatefulWidget {
  final Category? category;
  final String defaultType;

  const CategoryFormPage({super.key, this.category, this.defaultType = 'expense'});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _type = 'expense';
  String _selectedIcon = 'other_expense';

  bool get isEditing => widget.category != null;

  static const List<Map<String, String>> _iconOptions = [
    {'value': 'food', 'label': '🍔 餐饮'},
    {'value': 'transport', 'label': '🚗 交通'},
    {'value': 'shopping', 'label': '🛍️ 购物'},
    {'value': 'entertainment', 'label': '🎮 娱乐'},
    {'value': 'housing', 'label': '🏠 住房'},
    {'value': 'medical', 'label': '🏥 医疗'},
    {'value': 'education', 'label': '📚 教育'},
    {'value': 'salary', 'label': '💰 工资'},
    {'value': 'bonus', 'label': '🎁 奖金'},
    {'value': 'investment', 'label': '📈 投资'},
    {'value': 'other_expense', 'label': '📦 其他支出'},
    {'value': 'other_income', 'label': '💵 其他收入'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _type = widget.category!.type;
      _selectedIcon = widget.category!.icon;
    } else {
      _type = widget.defaultType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CategoryProvider>();
    final body = {
      'name': _nameController.text.trim(),
      'type': _type,
      'icon': _selectedIcon,
    };

    final success = isEditing
        ? await provider.updateCategory(widget.category!.id, body)
        : await provider.createCategory(body);

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
        title: Text(isEditing ? '编辑分类' : '添加分类'),
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
            // 收支类型切换
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

            // 分类名称
            TextFormField(
              controller: _nameController,
              validator: (v) => Validators.name(v, '分类名称'),
              decoration: const InputDecoration(
                labelText: '分类名称',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
            ),
            const SizedBox(height: 20),

            // 图标选择
            const Text(
              '选择图标',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _iconOptions.map((option) {
                final isSelected = _selectedIcon == option['value'];
                return ChoiceChip(
                  label: Text(option['label']!),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedIcon = option['value']!);
                  },
                  selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEditing ? '保存修改' : '添加分类'),
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
        onTap: () => setState(() => _type = type),
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
}
