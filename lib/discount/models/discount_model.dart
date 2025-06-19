class DiscountModel {
  final String cardId;
  final String customerName;
  final double amount;
  final DateTime expiry;

  DiscountModel({
    required this.cardId,
    required this.customerName,
    required this.amount,
    required this.expiry,
  });
}
