import 'transaction_item.dart';

class TransactionModel {
  final int? id;
  final String invoiceNumber;
  final DateTime transactionDate;
  final int totalAmount;
  final int paidAmount;
  final int changeAmount;
  final String paymentMethod;
  final String cashierName;
  final String? notes;
  final List<TransactionItem> items;

  TransactionModel({
    this.id,
    required this.invoiceNumber,
    required this.transactionDate,
    required this.totalAmount,
    required this.paidAmount,
    this.changeAmount = 0,
    required this.paymentMethod,
    this.cashierName = 'Staf Kasir',
    this.notes,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'invoiceNumber': invoiceNumber,
      'transactionDate': transactionDate.toIso8601String(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'changeAmount': changeAmount,
      'paymentMethod': paymentMethod,
      'cashierName': cashierName,
      'notes': notes,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, {List<TransactionItem> items = const []}) {
    return TransactionModel(
      id: map['id'] as int?,
      invoiceNumber: map['invoiceNumber'] as String? ?? '',
      transactionDate: DateTime.tryParse(map['transactionDate'] as String? ?? '') ?? DateTime.now(),
      totalAmount: (map['totalAmount'] as num?)?.toInt() ?? 0,
      paidAmount: (map['paidAmount'] as num?)?.toInt() ?? 0,
      changeAmount: (map['changeAmount'] as num?)?.toInt() ?? 0,
      paymentMethod: map['paymentMethod'] as String? ?? 'TUNAI',
      cashierName: map['cashierName'] as String? ?? 'Staf Kasir',
      notes: map['notes'] as String?,
      items: items,
    );
  }
}

