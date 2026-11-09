class Expense {
  final int? id;
  final DateTime expenseDate;
  final String category;
  final int amount;
  final String? notes;

  Expense({
    this.id,
    required this.expenseDate,
    required this.category,
    required this.amount,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'expenseDate': expenseDate.toIso8601String(),
      'category': category,
      'amount': amount,
      'notes': notes,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      expenseDate: DateTime.tryParse(map['expenseDate'] as String? ?? '') ?? DateTime.now(),
      category: map['category'] as String? ?? 'Operasional',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      notes: map['notes'] as String?,
    );
  }
}

