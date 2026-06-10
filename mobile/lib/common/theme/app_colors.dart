import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 主色 - 深邃蓝紫，更有质感
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF2E5A8F);
  static const Color primaryDark = Color(0xFF0F2440);

  // 收支颜色
  static const Color expense = Color(0xFFE85D5D);
  static const Color expenseLight = Color(0xFFFFE8E8);
  static const Color income = Color(0xFF34B87A);
  static const Color incomeLight = Color(0xFFE5F8EF);

  // 背景色
  static const Color background = Color(0xFFF4F6FB);
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFE8ECF2);

  // 文字色
  static const Color textPrimary = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF7B8794);
  static const Color textHint = Color(0xFFB8C1CC);

  // 功能色
  static const Color error = Color(0xFFE85D5D);
  static const Color success = Color(0xFF34B87A);
  static const Color warning = Color(0xFFF5A623);

  // 渐变色
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A5F), Color(0xFF3A6EA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceCardGradient = LinearGradient(
    colors: [Color(0xFF1E3A5F), Color(0xFF4A90D9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF34B87A), Color(0xFF5DD9A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFE85D5D), Color(0xFFFF8A80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 饼图颜色
  static const List<Color> chartColors = [
    Color(0xFF4A90D9),
    Color(0xFF34B87A),
    Color(0xFFF5A623),
    Color(0xFFE85D5D),
    Color(0xFF9B59B6),
    Color(0xFF1ABC9C),
    Color(0xFFE67E22),
    Color(0xFF7B8794),
    Color(0xFF2ECC71),
    Color(0xFFE74C3C),
  ];
}
