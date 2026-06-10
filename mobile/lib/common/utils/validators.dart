class Validators {
  Validators._();

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入用户名';
    }
    if (value.trim().length < 3) {
      return '用户名至少3个字符';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码至少6位';
    }
    return null;
  }

  static String? nickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入昵称';
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入金额';
    }
    final num = double.tryParse(value.trim());
    if (num == null) {
      return '请输入有效数字';
    }
    if (num <= 0) {
      return '金额必须大于0';
    }
    return null;
  }

  static String? required(String? value, [String field = '此字段']) {
    if (value == null || value.trim().isEmpty) {
      return '请输入$field';
    }
    return null;
  }

  static String? name(String? value, [String field = '名称']) {
    if (value == null || value.trim().isEmpty) {
      return '请输入$field';
    }
    return null;
  }
}
