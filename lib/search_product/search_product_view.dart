import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../product_details/product_details_view.dart';
import 'search_product_controller.dart';

class SearchProductView extends StatelessWidget {
  final controller = Get.put(SearchProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Products")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: "Search by product name",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: controller.searchProducts,
                ),
              ),
              onSubmitted: (_) => controller.searchProducts(),
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (controller.isLoading.value) {
                return const CircularProgressIndicator();
              } else if (controller.results.isEmpty) {
                return const Text("No results found");
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: controller.results.length,
                  itemBuilder: (context, index) {
                    final product = controller.results[index];
                    return Card(
                      child: ListTile(
                        onTap: () {
                          Get.to(() => ProductDetailsView(productId: product['id']));
                        },

                        leading: product['imageUrl'] != null
                            ? Image.network(product['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported),
                        title: Text(product['name'] ?? 'Unnamed'),
                        subtitle: Text("Buy: ${product['buyingPrice']} → MRP: ${product['mrp']}"),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
