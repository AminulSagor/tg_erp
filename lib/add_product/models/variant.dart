import 'package:cloud_firestore/cloud_firestore.dart';

class Variant {
  final String size;
  final double buyingPrice;
  final double mrp;
  final DateTime? expiryDate;
  final int? stock;
  final List<String>? colors;

  const Variant({
    required this.size,
    required this.buyingPrice,
    required this.mrp,
    this.expiryDate,
    this.stock,
    this.colors,
  });

  Map<String, dynamic> toMap() => {
    'size': size,
    'buyingPrice': buyingPrice,
    'mrp': mrp,
    if (expiryDate != null) 'expiryDate': Timestamp.fromDate(expiryDate!),
    if (stock != null) 'stock': stock,
    if (colors != null && colors!.isNotEmpty) 'colors': colors,
  };

  factory Variant.fromMap(Map<String, dynamic> map) => Variant(
    size: (map['size'] ?? '').toString(),
    buyingPrice: (map['buyingPrice'] ?? 0).toDouble(),
    mrp: (map['mrp'] ?? 0).toDouble(),
    expiryDate: map['expiryDate'] is Timestamp
        ? (map['expiryDate'] as Timestamp).toDate()
        : null,
    stock: map['stock'] != null ? int.tryParse(map['stock'].toString()) : null,
    colors: map['colors'] != null
        ? List<String>.from(map['colors'])
        : null,
  );
}
