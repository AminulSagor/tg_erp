import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tg_erp/add_product/product_service.dart';
import 'package:tg_erp/add_product/models/variant.dart';

class AddProductController extends GetxController {
  // ── Product (minimal) ──────────────────────────────────────────────────────
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final descriptionController = TextEditingController();
  final tagController = TextEditingController();

  // ── Variant inputs ─────────────────────────────────────────────────────────
  final variantSizeController = TextEditingController();
  final variantBuyingPriceController = TextEditingController();
  final variantMrpController = TextEditingController();
  final variantColorInputController = TextEditingController(); // text input for one color
  final variantStockController = TextEditingController();
  final variantExpiryDate = Rx<DateTime?>(null);
  final variantExpiryTextController = TextEditingController();

  // Multiple colors for the *current* variant being composed
  final variantColors = <String>[].obs;

  // ── State ──────────────────────────────────────────────────────────────────
  final tags = <String>[].obs;
  final showInWeb = false.obs;
  final imageFiles = <File>[].obs;
  final isUploading = false.obs;
  final variants = <Variant>[].obs;

  final picker = ImagePicker();
  final _productService = ProductService();

  // ── Images (max 5) ─────────────────────────────────────────────────────────
  Future<void> pickImage() async {
    if (imageFiles.length >= 5) {
      Get.snackbar("Limit Reached", "You can only upload up to 5 images.");
      return;
    }
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) imageFiles.add(File(picked.path));
  }

  void removeImage(int index) {
    if (index >= 0 && index < imageFiles.length) imageFiles.removeAt(index);
  }

  // ── Variant helpers ────────────────────────────────────────────────────────
  Future<void> pickVariantExpiryDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate != null) {
      variantExpiryDate.value = pickedDate;
      variantExpiryTextController.text =
      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
    }
  }

  // colors for current variant
  void addVariantColor([String? value]) {
    final raw = (value ?? variantColorInputController.text).trim();
    if (raw.isEmpty) return;
    if (!variantColors.contains(raw)) {
      variantColors.add(raw);
    }
    variantColorInputController.clear();
  }

  void removeVariantColor(String color) {
    variantColors.remove(color);
  }

  void clearVariantInputs() {
    variantSizeController.clear();
    variantBuyingPriceController.clear();
    variantMrpController.clear();
    variantStockController.clear();
    variantExpiryDate.value = null;
    variantExpiryTextController.clear();
    variantColorInputController.clear();
    variantColors.clear();
  }

  void addVariant() {
    final size = variantSizeController.text.trim();
    final buying = double.tryParse(variantBuyingPriceController.text) ?? 0;
    final mrp = double.tryParse(variantMrpController.text) ?? 0;
    final stockText = variantStockController.text.trim();
    final stock = stockText.isEmpty ? null : int.tryParse(stockText);

    if (size.isEmpty) {
      Get.snackbar("Validation", "Variant size is required.");
      return;
    }
    if (mrp <= 0) {
      Get.snackbar("Validation", "Variant MRP must be greater than 0.");
      return;
    }

    variants.add(Variant(
      size: size,
      buyingPrice: buying,
      mrp: mrp,
      expiryDate: variantExpiryDate.value,
      stock: stock,
      colors: variantColors.isEmpty ? null : variantColors.toList(), // ✅ multi-colors
    ));

    clearVariantInputs();
  }

  void removeVariantAt(int index) {
    if (index >= 0 && index < variants.length) variants.removeAt(index);
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> submitProduct() async {
    if (imageFiles.isEmpty || nameController.text.trim().isEmpty) {
      Get.snackbar("Validation", "Please provide product name and at least one image.");
      return;
    }
    if (variants.isEmpty) {
      Get.snackbar("Validation", "Add at least one variant.");
      return;
    }

    isUploading.value = true;
    try {
      final imageUrls = <String>[];
      for (final file in imageFiles) {
        final url = await _productService.uploadToSupabase(file);
        if (url != null) imageUrls.add(url);
      }
      if (imageUrls.isEmpty) {
        Get.snackbar("Upload Failed", "Image upload failed.");
        return;
      }

      await _productService.saveProduct(
        name: nameController.text.trim(),
        imageUrls: imageUrls,
        variants: variants.toList(), // ← core data
        category: categoryController.text.trim().isEmpty
            ? null
            : categoryController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        showInWeb: showInWeb.value,
        tags: tags.isNotEmpty ? tags.toList() : null,
      );

      Get.back();
      Get.snackbar("Success", "Product added successfully.");
    } catch (e) {
      Get.snackbar("Error", "Failed to add product: ${e.toString()}");
      // ignore: avoid_print
      print("❌ submitProduct error: $e");
    } finally {
      isUploading.value = false;
    }
  }

  // ── Cleanup ─────────────────────────────────────────────────────────────────
  @override
  void onClose() {
    nameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    tagController.dispose();

    variantSizeController.dispose();
    variantBuyingPriceController.dispose();
    variantMrpController.dispose();
    variantColorInputController.dispose();
    variantStockController.dispose();
    variantExpiryTextController.dispose();

    tags.clear();
    imageFiles.clear();
    variants.clear();
    variantColors.clear();
    super.onClose();
  }
}
