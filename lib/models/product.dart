class Product {
  final int? id;
  final String productCode;
  final String name;
  final String category;
  final int price;
  final int costPrice;
  final int stock;
  final String unit;
  final bool isActive;

  Product({
    this.id,
    required this.productCode,
    required this.name,
    required this.category,
    required this.price,
    this.costPrice = 0,
    this.stock = 0,
    this.unit = 'Butir',
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'productCode': productCode,
      'name': name,
      'category': category,
      'price': price,
      'costPrice': costPrice,
      'stock': stock,
      'unit': unit,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      productCode: map['productCode'] as String? ?? '',
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'Kelapa',
      price: (map['price'] as num?)?.toInt() ?? 0,
      costPrice: (map['costPrice'] as num?)?.toInt() ?? 0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      unit: map['unit'] as String? ?? 'Butir',
      isActive: (map['isActive'] as int? ?? 1) == 1,
    );
  }

  Product copyWith({
    int? id,
    String? productCode,
    String? name,
    String? category,
    int? price,
    int? costPrice,
    int? stock,
    String? unit,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      productCode: productCode ?? this.productCode,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
    );
  }
}

