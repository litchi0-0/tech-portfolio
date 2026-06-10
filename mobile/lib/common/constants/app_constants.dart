class AppConstants {
  AppConstants._();

  static const String appName = 'NuclearLedger';
  static const String tokenKey = 'auth_token';
  static const String defaultDateFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String monthFormat = 'yyyy-MM';
  static const String displayDateFormat = 'yyyy-MM-dd';

  // 默认分类 icon 映射
  static const Map<String, String> categoryIcons = {
    'food': '🍔',
    'transport': '🚗',
    'shopping': '🛍️',
    'entertainment': '🎮',
    'housing': '🏠',
    'medical': '🏥',
    'education': '📚',
    'other_expense': '📦',
    'salary': '💰',
    'bonus': '🎁',
    'investment': '📈',
    'other_income': '💵',
  };

  // 账户 icon 映射
  static const Map<String, String> accountIcons = {
    'cash': '💵',
    'bank_card': '🏦',
    'wechat': '💬',
    'alipay': '💙',
    'credit_card': '💳',
    'other': '📌',
  };
}
