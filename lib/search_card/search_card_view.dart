import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'search_card_controller.dart';

class SearchCardView extends StatelessWidget {
  SearchCardView({super.key});

  final controller = Get.put(SearchCardController());
  final cardIdController = TextEditingController();

  String formatDate(dynamic rawDate) {
    try {
      final date = DateTime.parse(rawDate.toString());
      return DateFormat('d MMMM yyyy').format(date); // Example: 25 July 2025
    } catch (_) {
      return rawDate.toString(); // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Discount Card")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: cardIdController,
              decoration: const InputDecoration(labelText: "Enter Card ID"),
              onChanged: (val) => controller.cardId.value = val,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: controller.searchCard,
              child: const Text("Search"),
            ),
            const SizedBox(height: 20),
            Obx(() {
              final card = controller.cardData.value;
              if (card == null) return const SizedBox();

              return Card(
                child: ListTile(
                  title: Text("Name: ${card['name']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Amount: ${card['amount']} TK"),
                      Text("Expiry: ${formatDate(card['expiry'])}"),
                      Text("Used: ${card['used'] == true ? 'Yes' : 'No'}"),
                      Text("Created At: ${formatDate(card['created_at'])}"),

                    ],
                  ),
                  trailing: card['used'] == true
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : ElevatedButton(
                    onPressed: controller.markAsUsed,
                    child: const Text("Mark as Used"),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
