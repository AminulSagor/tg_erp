import 'package:get/get.dart';
import 'package:tg_erp/search_card/search_card_controller.dart';
import 'package:tg_erp/search_card/search_card_view.dart';
import 'package:tg_erp/search_product/search_product_view.dart';
import 'add_product/add_product_view.dart';
import 'all_product/all_products_controller.dart';
import 'all_product/all_products_view.dart';
import 'discount/discount_card_view.dart';
import 'discount/discount_controller.dart';
import 'home/home_controller.dart';
import 'home/home_view.dart';


class AppRoutes {
  static const discountCard = '/card';
  static const searchCard = '/search';
  static const String addProduct = '/add-product';
  static const String home = '/';
  static const String searchProduct = '/search-product';
  static const String allProducts = '/all-products';

  static final routes = [
    GetPage(
      name: home,
      page: () => HomeView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
    ),
    GetPage(
      name: discountCard,
      page: () => const DiscountCardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DiscountController());
      }),
    ),
    GetPage(
      name: searchCard,
      page: () => SearchCardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SearchCardController());
      }),
    ),
    GetPage(name: addProduct, page: () => AddProductView()),

    GetPage(
      name: searchProduct,
      page: () => SearchProductView(),
    ),
    GetPage(
      name: allProducts,
      page: () => AllProductsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AllProductsController());
      }),
    ),
  ];
}
