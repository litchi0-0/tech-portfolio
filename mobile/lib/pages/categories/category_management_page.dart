import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../common/theme/app_colors.dart';
import '../../common/constants/app_constants.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/confirm_dialog.dart';
import '../../common/utils/snackbar_utils.dart';
import 'category_form_page.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('分类管理'),
        backgroundColor: AppColors.background,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '支出分类'),
            Tab(text: '收入分类'),
          ],
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const LoadingWidget();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(provider.expenseCategories, provider),
              _buildList(provider.incomeCategories, provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final isExpense = _tabController.index == 0;
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (_) => CategoryFormPage(defaultType: isExpense ? 'expense' : 'income'),
            ),
          )
              .then((_) {
            context.read<CategoryProvider>().fetchCategories();
          });
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildList(List categories, CategoryProvider provider) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📂', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('暂无分类', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final emoji = AppConstants.categoryIcons[category.icon] ?? '💰';
        final isExpense = category.type == 'expense';

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
                    builder: (_) => CategoryFormPage(category: category),
                  ),
                )
                    .then((_) {
                  provider.fetchCategories();
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isExpense ? '支出' : '收入',
                            style: TextStyle(
                              fontSize: 12,
                              color: isExpense ? AppColors.expense : AppColors.income,
                              fontWeight: FontWeight.w500,
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
                          title: '删除分类',
                          content: '确定要删除「${category.name}」吗？',
                          isDangerous: true,
                        );
                        if (confirmed == true) {
                          final success = await provider.deleteCategory(category.id);
                          if (context.mounted) {
                            if (!success) {
                              SnackbarUtils.showErrorSnackBar(
                                context,
                                provider.error ?? '删除失败',
                              );
                            }
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
      },
    );
  }
}
