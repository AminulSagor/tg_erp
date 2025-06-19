import 'package:get/get.dart';
import 'package:tg_erp/search_card/search_card_controller.dart';
import 'package:tg_erp/search_card/search_card_view.dart';
import 'discount/discount_card_view.dart';
import 'discount/discount_controller.dart';


class AppRoutes {
  static const discountCard = '/card';
  static const searchCard = '/search';

  static final routes = [
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
  ];
}
