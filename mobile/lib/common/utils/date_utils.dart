import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _monthFormat = DateFormat('yyyy-MM');
  static final DateFormat _displayFormat = DateFormat('MM月dd日');
  static final DateFormat _displayFullFormat = DateFormat('yyyy年MM月dd日 HH:mm');

  /// 格式化为后端所需的时间字符串
  static String toDateTimeString(DateTime dt) => _dateTimeFormat.format(dt);

  /// 格式化为日期字符串
  static String toDateString(DateTime dt) => _dateFormat.format(dt);

  /// 格式化为月份字符串 (yyyy-MM)
  static String toMonthString(DateTime dt) => _monthFormat.format(dt);

  /// 显示用：MM月dd日
  static String toDisplayDate(DateTime dt) => _displayFormat.format(dt);

  /// 显示用：yyyy年MM月dd日 HH:mm
  static String toDisplayFull(DateTime dt) => _displayFullFormat.format(dt);

  /// 从字符串解析为 DateTime
  static DateTime? parseDateTime(String? s) {
    if (s == null || s.isEmpty) return null;
    return _dateTimeFormat.parseLoose(s);
  }

  /// 获取今天的开始时间
  static DateTime todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 获取今天的结束时间
  static DateTime todayEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  /// 获取本月的开始时间
  static DateTime monthStart([DateTime? dt]) {
    final d = dt ?? DateTime.now();
    return DateTime(d.year, d.month, 1);
  }

  /// 获取本月的结束时间
  static DateTime monthEnd([DateTime? dt]) {
    final d = dt ?? DateTime.now();
    return DateTime(d.year, d.month + 1, 0, 23, 59, 59);
  }

  /// 当前时间字符串 (yyyy-MM-dd HH:mm:ss)
  static String nowString() => toDateTimeString(DateTime.now());

  /// 当前月份字符串 (yyyy-MM)
  static String currentMonth() => toMonthString(DateTime.now());
}
