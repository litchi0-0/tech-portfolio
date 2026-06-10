class Budget {
  final int id;
  final int? categoryId;
  final String? categoryName;
  final double amount;
  final String month; // yyyy-MM
  final String createdAt;
  final String updatedAt;

  Budget({
    required this.id,
    this.categoryId,
    this.categoryName,
    required this.amount,
    required this.month,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int?,
      categoryName: json['categoryName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as String,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'amount': amount,
        'month': month,
      };

  bool get isTotalBudget => categoryId == null;
}
