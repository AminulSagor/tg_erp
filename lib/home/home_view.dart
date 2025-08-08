import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../add_product/add_product_view.dart';
import '../discount/discount_card_view.dart';
import '../routes.dart';
import 'home_controller.dart';

class HomeView extends StatelessWidget {
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Get.toNamed(AppRoutes.addProduct);
              },
              child: const Text('Add Product'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(AppRoutes.discountCard);
              },
              child: const Text('Discount Card'),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(AppRoutes.searchProduct);
              },
              child: const Text('Search Product'),
            ),

            ElevatedButton(
              onPressed: () {
                Get.toNamed(AppRoutes.allProducts);
              },
              child: const Text('All Products'),
            ),

          ],
        ),
      ),
    );
  }
}
