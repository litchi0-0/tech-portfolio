import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../common/theme/app_colors.dart';
import '../../common/widgets/confirm_dialog.dart';
import '../auth/login_page.dart';
import '../categories/category_management_page.dart';
import '../accounts/account_management_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.user;
          return ListView(
            children: [
              // 用户信息卡片
              Container(
                margin: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          (user?.nickname ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.nickname ?? '未登录',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${user?.username ?? '-'}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // 功能列表
              _buildMenuSection([
                _MenuItem(
                  icon: Icons.category_outlined,
                  activeIcon: Icons.category_rounded,
                  title: '分类管理',
                  subtitle: '管理收支分类',
                  color: const Color(0xFF4A90D9),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CategoryManagementPage()),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet_rounded,
                  title: '账户管理',
                  subtitle: '管理你的账户',
                  color: const Color(0xFF34B87A),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AccountManagementPage()),
                    );
                  },
                ),
              ]),

              const SizedBox(height: 12),

              _buildMenuSection([
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  activeIcon: Icons.info_rounded,
                  title: '关于',
                  subtitle: 'NuclearLedger v1.0.0',
                  color: const Color(0xFF9B59B6),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'NuclearLedger',
                      applicationVersion: '1.0.0',
                      applicationIcon: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      children: [
                        const Text('一款简洁的个人记账应用'),
                      ],
                    );
                  },
                ),
              ]),

              const SizedBox(height: 12),

              // 退出登录
              _buildMenuSection([
                _MenuItem(
                  icon: Icons.logout_rounded,
                  activeIcon: Icons.logout_rounded,
                  title: '退出登录',
                  color: AppColors.error,
                  onTap: () async {
                    final confirmed = await ConfirmDialog.show(
                      context,
                      title: '退出登录',
                      content: '确定要退出登录吗？',
                      confirmText: '退出',
                      isDangerous: true,
                    );
                    if (confirmed == true && context.mounted) {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    }
                  },
                ),
              ]),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuSection(List<_MenuItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: items.map((item) {
          final isNotLast = items.last != item;
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: items.first == item ? const Radius.circular(14) : Radius.zero,
                    bottom: items.last == item ? const Radius.circular(14) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: (item.color ?? AppColors.primary).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.icon,
                            color: item.color ?? AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: item.color ?? AppColors.textPrimary,
                                ),
                              ),
                              if (item.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item.subtitle!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: AppColors.textHint,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isNotLast)
                Padding(
                  padding: const EdgeInsets.only(left: 68),
                  child: Divider(height: 1, color: AppColors.divider.withValues(alpha: 0.6)),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    this.activeIcon = Icons.circle,
    required this.title,
    this.subtitle,
    this.color,
    required this.onTap,
  });
}
