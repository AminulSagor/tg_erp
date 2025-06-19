import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/discount_model.dart';

class DiscountController extends GetxController {
  var discount = Rxn<DiscountModel>();

  void generateDiscount({
    required String customerName,
    required double amount,
    required DateTime expiry,
  }) async {
    final cardId = (1000000000 + (DateTime.now().millisecondsSinceEpoch % 9000000000)).toString();

    final newDiscount = DiscountModel(
      cardId: cardId,
      customerName: customerName,
      amount: amount,
      expiry: expiry,
    );

    discount.value = newDiscount;

    // ✅ Save to Firebase Firestore
    await FirebaseFirestore.instance.collection('customer_info').add({
      'name': customerName,
      'amount': amount,
      'expiry': expiry.toIso8601String(),
      'card_id': cardId,
      'used': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
