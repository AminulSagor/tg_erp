import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'all_products_controller.dart';
import '../product_details/product_details_view.dart';

class AllProductsView extends StatelessWidget {
  final controller = Get.put(AllProductsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Products")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: "Search product name",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: controller.fetchProducts,
                ),
              ),
              onSubmitted: (_) => controller.fetchProducts(),
            ),
            const SizedBox(height: 16),
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : Expanded(
              child: ListView.builder(
                controller: controller.scrollController,
                itemCount: controller.products.length +
                    (controller.isMoreLoading.value ? 1 : 0),
                itemBuilder: (_, productIndex) {
                  if (productIndex >= controller.products.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final product = controller.products[productIndex];
                  final variants = product['variants'] ?? [];

                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      leading: product['imageUrl'] != null
                          ? Image.network(product['imageUrl'],
                          width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image_not_supported),
                      title: Text(product['name'] ?? 'No Name'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "৳${product['buyingPrice']} → ৳${product['mrp']}",
                            style:
                            TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          if (variants.isNotEmpty)
                            Column(
                              children: List.generate(
                                variants.length,
                                    (variantIndex) {
                                  final v = variants[variantIndex];
                                  return Row(
                                    children: [
                                      Text(
                                        "${v['name'] ?? 'Variant'}: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.remove_circle_outline),
                                        onPressed: () => controller.decreaseVariantStock(
                                            productIndex, variantIndex),
                                      ),
                                      Text(
                                        "${v['stock'] ?? 0}",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline),
                                        onPressed: () => controller.increaseVariantStock(
                                            productIndex, variantIndex),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )
                          else
                            Text(
                              "No variants found",
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                      onTap: () => Get.to(() =>
                          ProductDetailsView(productId: product['id'])),
                      onLongPress: () =>
                          controller.confirmDelete(product['id']),
                    ),
                  );
                },
              ),
            )),
          ],
        ),
      ),
    );
  }
}
