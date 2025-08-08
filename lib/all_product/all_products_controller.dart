import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../add_product/product_service.dart';
import '../add_product/models/variant.dart';

class AllProductsController extends GetxController {
  final searchController = TextEditingController();
  final products = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final hasMore = true.obs;

  final _service = ProductService();
  DocumentSnapshot? _lastDocument;
  final int pageSize = 10;
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    scrollController.addListener(_onScroll);
  }

  /// Fetch first page of products
  void fetchProducts() async {
    isLoading.value = true;
    _lastDocument = null;
    hasMore.value = true;

    try {
      final result = await _service.searchProductsByName(
        searchText: searchController.text,
        limit: pageSize,
      );
      products.value = result.items;
      _lastDocument = result.lastDoc;
      hasMore.value = result.items.length == pageSize;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more products for pagination
  void loadMoreProducts() async {
    if (!hasMore.value || isMoreLoading.value) return;

    isMoreLoading.value = true;
    try {
      final result = await _service.searchProductsByName(
        searchText: searchController.text,
        limit: pageSize,
        startAfter: _lastDocument,
      );
      products.addAll(result.items);
      _lastDocument = result.lastDoc;
      hasMore.value = result.items.length == pageSize;
    } finally {
      isMoreLoading.value = false;
    }
  }

  /// Confirm and delete a product
  void confirmDelete(String productId) {
    Get.defaultDialog(
      title: 'Delete Product',
      middleText: 'Are you sure you want to delete this product?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await _service.deleteProduct(productId);
        fetchProducts();
        Get.back();
        Get.snackbar("Deleted", "Product has been deleted.");
      },
    );
  }

  /// Increase stock for a specific variant
  void increaseVariantStock(int productIndex, int variantIndex) async {
    final product = products[productIndex];
    final List variantsData = product['variants'] ?? [];

    if (variantsData.isEmpty) return;

    // Convert to Variant model
    final variants = variantsData
        .map((v) => Variant.fromMap(Map<String, dynamic>.from(v)))
        .toList();

    final oldVariant = variants[variantIndex];
    final updatedVariant = Variant(
      size: oldVariant.size,
      buyingPrice: oldVariant.buyingPrice,
      mrp: oldVariant.mrp,
      expiryDate: oldVariant.expiryDate,
      colors: oldVariant.colors, // <-- keep colors if you support multiple
      stock: (oldVariant.stock ?? 0) + 1,
    );

    variants[variantIndex] = updatedVariant;

    // Update Firestore
    await _service.updateVariants(product['id'], variants);

    // Update local state
    product['variants'][variantIndex]['stock'] = updatedVariant.stock;
    products.refresh();
  }

  /// Decrease stock for a specific variant
  void decreaseVariantStock(int productIndex, int variantIndex) async {
    final product = products[productIndex];
    final List variantsData = product['variants'] ?? [];

    if (variantsData.isEmpty) return;

    final variants = variantsData
        .map((v) => Variant.fromMap(Map<String, dynamic>.from(v)))
        .toList();

    final oldVariant = variants[variantIndex];
    if ((oldVariant.stock ?? 0) > 0) {
      final updatedVariant = Variant(
        size: oldVariant.size,
        buyingPrice: oldVariant.buyingPrice,
        mrp: oldVariant.mrp,
        expiryDate: oldVariant.expiryDate,
        colors: oldVariant.colors,
        stock: oldVariant.stock! - 1,
      );

      variants[variantIndex] = updatedVariant;

      await _service.updateVariants(product['id'], variants);

      product['variants'][variantIndex]['stock'] = updatedVariant.stock;
      products.refresh();
    }
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMoreProducts();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
