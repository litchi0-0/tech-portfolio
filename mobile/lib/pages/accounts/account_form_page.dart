import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../common/theme/app_colors.dart';
import '../../common/utils/validators.dart';
import '../../common/utils/snackbar_utils.dart';
import '../../models/account.dart';

class AccountFormPage extends StatefulWidget {
  final Account? account;

  const AccountFormPage({super.key, this.account});

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _type = 'cash';

  bool get isEditing => widget.account != null;

  static const List<Map<String, String>> _accountTypes = [
    {'value': 'cash', 'label': '💵 现金'},
    {'value': 'bank_card', 'label': '🏦 银行卡'},
    {'value': 'wechat', 'label': '💬 微信'},
    {'value': 'alipay', 'label': '💙 支付宝'},
    {'value': 'credit_card', 'label': '💳 信用卡'},
    {'value': 'other', 'label': '📌 其他'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _nameController.text = widget.account!.name;
      _balanceController.text = widget.account!.balance.toString();
      _type = widget.account!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AccountProvider>();
    final body = {
      'name': _nameController.text.trim(),
      'type': _type,
      'balance': double.tryParse(_balanceController.text.trim()) ?? 0,
    };

    final success = isEditing
        ? await provider.updateAccount(widget.account!.id, body)
        : await provider.createAccount(body);

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
        title: Text(isEditing ? '编辑账户' : '添加账户'),
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
            TextFormField(
              controller: _nameController,
              validator: (v) => Validators.name(v, '账户名称'),
              decoration: const InputDecoration(
                labelText: '账户名称',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '账户类型',
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
              children: _accountTypes.map((option) {
                final isSelected = _type == option['value'];
                return ChoiceChip(
                  label: Text(option['label']!),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _type = option['value']!);
                  },
                  selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '初始余额',
                prefixText: '¥ ',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEditing ? '保存修改' : '添加账户'),
            ),
          ],
        ),
      ),
    );
  }
}
