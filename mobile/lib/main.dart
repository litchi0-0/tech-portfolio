import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api/dio_client.dart';
import 'api/services/auth_service.dart';
import 'api/services/user_service.dart';
import 'api/services/transaction_service.dart';
import 'api/services/category_service.dart';
import 'api/services/account_service.dart';
import 'api/services/budget_service.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/tab_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/category_provider.dart';
import 'providers/account_provider.dart';
import 'providers/budget_provider.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化依赖
  final dioClient = DioClient();

  final authService = AuthService(dioClient);
  final userService = UserService(dioClient);
  final transactionService = TransactionService(dioClient);
  final categoryService = CategoryService(dioClient);
  final accountService = AccountService(dioClient);
  final budgetService = BudgetService(dioClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => UserProvider(userService)),
        ChangeNotifierProvider(create: (_) => TabProvider()),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(transactionService),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(categoryService),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountProvider(accountService),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetProvider(budgetService),
        ),
      ],
      child: const NuclearLedgerApp(),
    ),
  );
}
