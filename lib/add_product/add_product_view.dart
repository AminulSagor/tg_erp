import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_product_controller.dart';

class AddProductView extends StatelessWidget {
  final controller = Get.put(AddProductController(), permanent: true);

  AddProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Images ────────────────────────────────────────────────────────
            Obx(
                  () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...controller.imageFiles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final file = entry.value;
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                file,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => controller.removeImage(index),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child:
                                  Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      if (controller.imageFiles.length < 5)
                        GestureDetector(
                          onTap: controller.pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_a_photo),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text("You can upload up to 5 images."),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Product Name ─────────────────────────────────────────────────
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),

            const SizedBox(height: 16),

            // ── Variants ─────────────────────────────────────────────────────
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Variants (size + colors + stock + buying price + MRP + expiry)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: controller.variantSizeController,
              decoration: const InputDecoration(
                labelText: 'Variant Size (e.g., 200g, L)',
              ),
            ),

            // MULTI-COLOR INPUT FOR VARIANT
            Obx(
                  () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: -8,
                    children: controller.variantColors
                        .map(
                          (c) => Chip(
                        label: Text(c),
                        onDeleted: () => controller.removeVariantColor(c),
                      ),
                    )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.variantColorInputController,
                          decoration: const InputDecoration(
                            labelText: 'Add Variant Color',
                          ),
                          onSubmitted: controller.addVariantColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: controller.addVariantColor,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            TextField(
              controller: controller.variantStockController,
              decoration: const InputDecoration(
                labelText: 'Variant Stock (optional)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: controller.variantBuyingPriceController,
              decoration: const InputDecoration(
                labelText: 'Variant Buying Price',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: controller.variantMrpController,
              decoration: const InputDecoration(
                labelText: 'Variant MRP',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: controller.variantExpiryTextController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Variant Expiry Date (optional)',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => controller.pickVariantExpiryDate(context),
            ),

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: controller.addVariant,
                icon: const Icon(Icons.add),
                label: const Text('Add Variant'),
              ),
            ),

            const SizedBox(height: 8),

            // ── Variant List ─────────────────────────────────────────────────
            Obx(
                  () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.variants.isEmpty)
                    const Text("No variants added yet."),
                  for (int i = 0; i < controller.variants.length; i++)
                    Card(
                      child: ListTile(
                        dense: true,
                        title: Text(
                          "Size: ${controller.variants[i].size}"
                              "${controller.variants[i].colors != null && controller.variants[i].colors!.isNotEmpty ? ' | Colors: ${controller.variants[i].colors!.join(', ')}' : ''}"
                              "${controller.variants[i].stock != null ? ' | Stock: ${controller.variants[i].stock}' : ''}",
                        ),
                        subtitle: Text(
                          "Buying: ${controller.variants[i].buyingPrice} | "
                              "MRP: ${controller.variants[i].mrp} | "
                              "Expiry: ${controller.variants[i].expiryDate != null ? controller.variants[i].expiryDate!.toIso8601String().split('T').first : '—'}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.removeVariantAt(i),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // ── Tags ─────────────────────────────────────────────────────────
            Obx(
                  () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    children: controller.tags
                        .map(
                          (tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => controller.tags.remove(tag),
                      ),
                    )
                        .toList(),
                  ),
                  TextField(
                    controller: controller.tagController,
                    decoration: const InputDecoration(labelText: 'Add Tag'),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        controller.tags.add(val.trim());
                        controller.tagController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Category / Description / Show in Web ─────────────────────────
            TextField(
              controller: controller.categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: controller.descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            Obx(
                  () => CheckboxListTile(
                value: controller.showInWeb.value,
                onChanged: (val) => controller.showInWeb.value = val ?? false,
                title: const Text("Show in Website"),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),

            const SizedBox(height: 20),

            // ── Submit ───────────────────────────────────────────────────────
            Obx(
                  () => ElevatedButton(
                onPressed:
                controller.isUploading.value ? null : controller.submitProduct,
                child: controller.isUploading.value
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
