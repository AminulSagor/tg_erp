import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SearchCardController extends GetxController {
  final cardId = ''.obs;
  final cardData = Rxn<Map<String, dynamic>>();
  String? foundDocId;

  Future<void> searchCard() async {
    final id = cardId.value.trim();
    if (id.isEmpty) return;

    final query = await FirebaseFirestore.instance
        .collection('customer_info')
        .where('card_id', isEqualTo: id)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      cardData.value = query.docs.first.data();
      foundDocId = query.docs.first.id;
    } else {
      Get.snackbar("Not Found", "No card found with this ID");
      cardData.value = null;
      foundDocId = null;
    }
  }

  Future<void> markAsUsed() async {
    if (foundDocId == null) return;

    await FirebaseFirestore.instance
        .collection('customer_info')
        .doc(foundDocId)
        .update({'used': true});

    Get.snackbar("Success", "Card marked as used");
    cardData.update((val) {
      if (val != null) val['used'] = true;
    });
  }
}
