class Transaction {
  final int id;
  final int accountId;
  final int categoryId;
  final String categoryName;
  final String accountName;
  final double amount;
  final String type; // 'expense' | 'income'
  final String? note;
  final String transactionDate;
  final String createdAt;
  final String updatedAt;

  Transaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.categoryName,
    required this.accountName,
    required this.amount,
    required this.type,
    this.note,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      accountId: json['accountId'] as int,
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String? ?? '',
      accountName: json['accountName'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      note: json['note'] as String?,
      transactionDate: json['transactionDate'] as String,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'categoryId': categoryId,
        'amount': amount,
        'type': type,
        'note': note,
        'transactionDate': transactionDate,
      };

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';
}
