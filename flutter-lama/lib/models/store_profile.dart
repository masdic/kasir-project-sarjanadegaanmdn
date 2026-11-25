class StoreProfile {
  final int? id;
  final String storeName;
  final String branchName;
  final String address;
  final String phone;
  final String receiptFooter;

  StoreProfile({
    this.id,
    this.storeName = 'Sarjana Degan',
    required this.branchName,
    this.address = 'Madiun, Jawa Timur',
    this.phone = '081234567890',
    this.receiptFooter = 'Terima Kasih Atas Kunjungan Anda! Segarnya Kelapa Alami.',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'storeName': storeName,
      'branchName': branchName,
      'address': address,
      'phone': phone,
      'receiptFooter': receiptFooter,
    };
  }

  factory StoreProfile.fromMap(Map<String, dynamic> map) {
    return StoreProfile(
      id: map['id'] as int?,
      storeName: map['storeName'] as String? ?? 'Sarjana Degan',
      branchName: map['branchName'] as String? ?? 'Cabang 1',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      receiptFooter: map['receiptFooter'] as String? ?? '',
    );
  }

  StoreProfile copyWith({
    int? id,
    String? storeName,
    String? branchName,
    String? address,
    String? phone,
    String? receiptFooter,
  }) {
    return StoreProfile(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      branchName: branchName ?? this.branchName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      receiptFooter: receiptFooter ?? this.receiptFooter,
    );
  }
}

