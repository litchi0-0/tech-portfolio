class Category {
  final int id;
  final String name;
  final String type; // 'expense' | 'income'
  final String icon;
  final String color;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.icon = '',
    this.color = '#636E72',
    this.sortOrder = 0,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String? ?? '',
      color: json['color'] as String? ?? '#636E72',
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'icon': icon,
        'color': color,
        'sortOrder': sortOrder,
      };

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';
}
