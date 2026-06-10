import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tab_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/budget_provider.dart';
import '../../common/theme/app_colors.dart';
import '../../common/utils/date_utils.dart' as app_date;
import '../home/tab_home.dart';
import '../statistics/statistics_page.dart';
import '../profile/profile_page.dart';
import '../add_record/add_record_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final startDate = app_date.AppDateUtils.toDateTimeString(
      DateTime(now.year, now.month, 1),
    );
    final endDate = app_date.AppDateUtils.toDateTimeString(
      DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );

    await Future.wait([
      context.read<TransactionProvider>().fetchTransactions(
            startDate: startDate,
            endDate: endDate,
          ),
      context.read<CategoryProvider>().fetchCategories(),
      context.read<AccountProvider>().fetchAccounts(),
      context.read<BudgetProvider>().fetchBudgets(
            month: app_date.AppDateUtils.toMonthString(now),
          ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TabProvider>(
      builder: (context, tabProvider, _) {
        return Scaffold(
          body: IndexedStack(
            index: tabProvider.currentIndex,
            children: const [
              TabHome(),
              SizedBox.shrink(),
              StatisticsPage(),
              ProfilePage(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: '首页',
                      isActive: tabProvider.currentIndex == 0,
                      onTap: () => tabProvider.setIndex(0),
                    ),
                    _NavItem(
                      icon: Icons.bar_chart_outlined,
                      activeIcon: Icons.bar_chart_rounded,
                      label: '统计',
                      isActive: tabProvider.currentIndex == 2,
                      onTap: () => tabProvider.setIndex(2),
                    ),
                    // 中间记账按钮
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddRecordPage()),
                        ).then((_) => _loadData());
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: '我的',
                      isActive: tabProvider.currentIndex == 3,
                      onTap: () => tabProvider.setIndex(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
