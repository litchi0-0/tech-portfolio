import 'package:intl/intl.dart';

class MoneyUtils {
  MoneyUtils._();

  static final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'zh_CN');

  /// 格式化金额，例如 1234.5 -> "1,234.50"
  static String format(double amount) => _currencyFormat.format(amount);

  /// 简洁格式：1234.5 -> "1,234.5"，整数时去掉小数位
  static String formatCompact(double amount) {
    if (amount == amount.roundToDouble()) {
      return NumberFormat('#,##0', 'zh_CN').format(amount);
    }
    return NumberFormat('#,##0.0#', 'zh_CN').format(amount);
  }

  /// 收支显示：支出加负号
  static String formatWithSign(double amount, String type) {
    if (type == 'expense') {
      return '-${format(amount)}';
    }
    return '+${format(amount)}';
  }
}
