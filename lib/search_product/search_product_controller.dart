import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../add_product/product_service.dart';

class SearchProductController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final isLoading = false.obs;
  final results = <Map<String, dynamic>>[].obs;

  final _service = ProductService();

  void searchProducts() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;

    isLoading.value = true;
    final result = await _service.searchProductsByName(searchText: query);
    results.assignAll(result.items); // since you're interested in the list only

    isLoading.value = false;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
