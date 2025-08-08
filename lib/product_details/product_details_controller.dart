import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../add_product/product_service.dart';
import '../add_product/models/variant.dart';

class ProductDetailsController extends GetxController {
  final product = Rxn<Map<String, dynamic>>();
  final variants = <Variant>[].obs;

  final _service = ProductService();

  // ── Load product and parse variants ────────────────────────────────────────
  void loadProduct(String id) async {
    final data = await _service.getProductById(id);
    if (data != null) {
      product.value = data;
      variants.assignAll(
        (data['variants'] as List<dynamic>? ?? [])
            .map((v) => Variant.fromMap(Map<String, dynamic>.from(v)))
            .toList(),
      );
    }
  }

  // ── Add / remove variant ───────────────────────────────────────────────────
  void addVariant() {
    variants.add(
      Variant(
        size: '',            // required by your model
        buyingPrice: 0.0,
        mrp: 0.0,
        stock: 0,
        colors: <String>[],
        // expiryDate: null,
      ),
    );
  }

  void removeVariant(int index) {
    if (index >= 0 && index < variants.length) {
      variants.removeAt(index);
    }
  }

  // ── Immutable update helpers (because Variant fields are final) ────────────
  Variant _copyVariant(
      Variant v, {
        String? size,
        double? buyingPrice,
        double? mrp,
        int? stock,
        DateTime? expiryDate, // pass null explicitly to clear if you want
        List<String>? colors,
      }) {
    return Variant(
      size: size ?? v.size,
      buyingPrice: buyingPrice ?? v.buyingPrice,
      mrp: mrp ?? v.mrp,
      expiryDate: expiryDate ?? v.expiryDate,
      stock: stock ?? v.stock,
      colors: colors ?? v.colors,
    );
  }

  void setVariantSize(int index, String val) {
    final v = variants[index];
    variants[index] = _copyVariant(v, size: val.trim());
    variants.refresh();
  }

  void setVariantBuying(int index, double value) {
    final v = variants[index];
    variants[index] = _copyVariant(v, buyingPrice: value);
    variants.refresh();
  }

  void setVariantMrp(int index, double value) {
    final v = variants[index];
    variants[index] = _copyVariant(v, mrp: value);
    variants.refresh();
  }

  void setVariantStock(int index, int value) {
    final v = variants[index];
    variants[index] = _copyVariant(v, stock: value);
    variants.refresh();
  }

  void setVariantExpiry(int index, DateTime? dt) {
    final v = variants[index];
    variants[index] = _copyVariant(v, expiryDate: dt);
    variants.refresh();
  }

  void addVariantColor(int index, String color) {
    final v = variants[index];
    final next = List<String>.from(v.colors ?? []);
    final c = color.trim();
    if (c.isEmpty) return;
    if (!next.contains(c)) next.add(c);
    variants[index] = _copyVariant(v, colors: next);
    variants.refresh();
  }

  void removeVariantColor(int index, String color) {
    final v = variants[index];
    final next = List<String>.from(v.colors ?? []);
    next.remove(color);
    variants[index] = _copyVariant(v, colors: next);
    variants.refresh();
  }

  // ── Persist changes ────────────────────────────────────────────────────────
  Future<void> updateProduct(String id) async {
    await _service.updateVariants(id, variants.toList());
    Get.snackbar("Success", "Product updated");
  }

  // ── Image re-upload (kept from your code) ──────────────────────────────────
  Future<void> pickAndReuploadImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final newUrl = await _service.reuploadProductImage(File(picked.path));
    if (newUrl != null) {
      final id = product.value!['id'];
      await _service.updateProduct(id: id, imageUrl: newUrl);
      product.update((val) {
        if (val != null) val['imageUrl'] = newUrl;
      });
      Get.snackbar("Updated", "Image reuploaded");
    }
  }
}
