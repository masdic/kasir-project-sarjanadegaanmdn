class ProductionLog {
  final int? id;
  final DateTime productionDate;
  final int coconutUsed;
  final int cupProduced;
  final String? notes;

  ProductionLog({
    this.id,
    required this.productionDate,
    required this.coconutUsed,
    required this.cupProduced,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'productionDate': productionDate.toIso8601String(),
      'coconutUsed': coconutUsed,
      'cupProduced': cupProduced,
      'notes': notes,
    };
  }

  factory ProductionLog.fromMap(Map<String, dynamic> map) {
    return ProductionLog(
      id: map['id'] as int?,
      productionDate: DateTime.tryParse(map['productionDate'] as String? ?? '') ?? DateTime.now(),
      coconutUsed: (map['coconutUsed'] as num?)?.toInt() ?? 0,
      cupProduced: (map['cupProduced'] as num?)?.toInt() ?? 0,
      notes: map['notes'] as String?,
    );
  }
}

