import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../common/theme/app_colors.dart';
import '../../common/constants/app_constants.dart';
import '../../common/utils/money_utils.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/confirm_dialog.dart';
import '../../common/utils/snackbar_utils.dart';
import 'account_form_page.dart';

class AccountManagementPage extends StatelessWidget {
  const AccountManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('账户管理'),
        backgroundColor: AppColors.background,
      ),
      body: Consumer<AccountProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const LoadingWidget();

          if (provider.accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💳', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  const Text('暂无账户', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 总资产
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 20),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '总资产',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '¥${MoneyUtils.format(provider.totalBalance)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),

              // 账户列表
              ...provider.accounts.map((account) {
                final emoji = AppConstants.accountIcons[account.type] ?? '📌';
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
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (_) => AccountFormPage(account: account),
                          ),
                        )
                            .then((_) => provider.fetchAccounts());
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(emoji, style: const TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '余额: ¥${MoneyUtils.format(account.balance)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 20),
                              onPressed: () async {
                                final confirmed = await ConfirmDialog.show(
                                  context,
                                  title: '删除账户',
                                  content: '确定要删除「${account.name}」吗？',
                                  isDangerous: true,
                                );
                                if (confirmed == true && context.mounted) {
                                  final success = await provider.deleteAccount(account.id);
                                  if (context.mounted && !success) {
                                    SnackbarUtils.showErrorSnackBar(
                                      context,
                                      provider.error ?? '删除失败',
                                    );
                                  }
                                }
                              },
                              style: IconButton.styleFrom(
                                foregroundColor: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(builder: (_) => const AccountFormPage()),
          )
              .then((_) {
            context.read<AccountProvider>().fetchAccounts();
          });
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
