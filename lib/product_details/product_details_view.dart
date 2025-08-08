import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'product_details_controller.dart';

class ProductDetailsView extends StatelessWidget {
  final String productId;
  final controller = Get.put(ProductDetailsController());

  ProductDetailsView({required this.productId});

  @override
  Widget build(BuildContext context) {
    controller.loadProduct(productId);

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addVariant,
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        final product = controller.product.value;
        if (product == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: controller.pickAndReuploadImage,
                child: product['imageUrl'] != null
                    ? Image.network(product['imageUrl'], height: 150)
                    : const Icon(Icons.image, size: 100),
              ),
              const SizedBox(height: 20),

              // --- VARIANTS LIST ---
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.variants.length,
                itemBuilder: (context, index) {
                  final v = controller.variants[index];

                  final colors = (v.colors ?? <String>[]);
                  final sizeController = TextEditingController(text: v.size);
                  final buyingController =
                  TextEditingController(text: v.buyingPrice.toString());
                  final mrpController =
                  TextEditingController(text: v.mrp.toString());
                  final stockController =
                  TextEditingController(text: (v.stock ?? 0).toString());

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: sizeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Variant Size (e.g., 200g, L)',
                                  ),
                                  onChanged: (val) =>
                                      controller.setVariantSize(index, val),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => controller.removeVariant(index),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: buyingController,
                            decoration: const InputDecoration(
                              labelText: 'Buying Price',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => controller.setVariantBuying(
                              index,
                              double.tryParse(val) ?? 0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: mrpController,
                            decoration: const InputDecoration(
                              labelText: 'MRP',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => controller.setVariantMrp(
                              index,
                              double.tryParse(val) ?? 0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: stockController,
                            decoration: const InputDecoration(
                              labelText: 'Stock',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => controller.setVariantStock(
                              index,
                              int.tryParse(val) ?? 0,
                            ),
                          ),

                          const SizedBox(height: 12),
                          // Expiry date
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Expiry: ${v.expiryDate != null ? v.expiryDate!.toIso8601String().split("T").first : "—"}',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.calendar_today),
                                label: const Text('Set date'),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: v.expiryDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                                  );
                                  controller.setVariantExpiry(index, picked);
                                },
                              ),
                              if (v.expiryDate != null)
                                TextButton(
                                  onPressed: () => controller.setVariantExpiry(index, null),
                                  child: const Text('Clear'),
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Text("Colors:"),
                          Wrap(
                            spacing: 6,
                            children: colors
                                .map(
                                  (c) => Chip(
                                label: Text(c),
                                onDeleted: () =>
                                    controller.removeVariantColor(index, c),
                              ),
                            )
                                .toList(),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Add Color'),
                                  onSubmitted: (val) =>
                                      controller.addVariantColor(index, val),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // grab from the previous TextField via a controller if you want a button
                                  // here we keep it simple and rely on onSubmitted above
                                  FocusScope.of(context).unfocus();
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.updateProduct(productId),
                child: const Text('Update Product'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
