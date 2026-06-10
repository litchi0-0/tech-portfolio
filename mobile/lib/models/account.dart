class Account {
  final int id;
  final String name;
  final String type; // cash, bank_card, wechat, alipay, credit_card, other
  final double balance;
  final String icon;
  final String color;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;

  Account({
    required this.id,
    required this.name,
    required this.type,
    this.balance = 0,
    this.icon = '',
    this.color = '#2D3436',
    this.sortOrder = 0,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      icon: json['icon'] as String? ?? '',
      color: json['color'] as String? ?? '#2D3436',
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'balance': balance,
        'icon': icon,
        'color': color,
        'sortOrder': sortOrder,
      };
}
