class TransactionItem {
  final int? id;
  final int? transactionId;
  final int productId;
  final String productName;
  final int priceAtSale;
  final int quantity;
  final int subtotal;

  TransactionItem({
    this.id,
    this.transactionId,
    required this.productId,
    required this.productName,
    required this.priceAtSale,
    required this.quantity,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (transactionId != null) 'transactionId': transactionId,
      'productId': productId,
      'productName': productName,
      'priceAtSale': priceAtSale,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as int?,
      transactionId: map['transactionId'] as int?,
      productId: map['productId'] as int? ?? 0,
      productName: map['productName'] as String? ?? '',
      priceAtSale: (map['priceAtSale'] as num?)?.toInt() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      subtotal: (map['subtotal'] as num?)?.toInt() ?? 0,
    );
  }
}

