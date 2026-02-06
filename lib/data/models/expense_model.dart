class Expense {
  final String id;
  final String description;
  final double value;
  final DateTime date;
  final String category; // Combustível, Manutenção, Seguro, etc.

  Expense({
    required this.id,
    required this.description,
    required this.value,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'value': value,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date']),
      category: json['category'] ?? '',
    );
  }
}
