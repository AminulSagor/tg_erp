import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'discount_controller.dart';
import 'widgets/discount_card.dart';

class DiscountCardView extends StatefulWidget {
  const DiscountCardView({super.key});

  @override
  State<DiscountCardView> createState() => _DiscountCardViewState();
}

class _DiscountCardViewState extends State<DiscountCardView> {
  final controller = Get.find<DiscountController>();
  final screenshotController = ScreenshotController();
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  DateTime? expiryDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Discount Card')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          final discount = controller.discount.value;

          return Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Discount Amount (TK)'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(expiryDate == null
                      ? 'Select Expiry Date'
                      : 'Expiry: ${expiryDate!.toLocal().toString().split(' ')[0]}'),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          expiryDate = picked;
                        });
                      }
                    },
                    child: const Text('Pick Date'),
                  )
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final amount = double.tryParse(amountController.text.trim());
                  if (name.isEmpty || amount == null || expiryDate == null) {
                    Get.snackbar("Invalid Input", "Fill all fields properly");
                    return;
                  }
                  controller.generateDiscount(
                    customerName: name,
                    amount: amount,
                    expiry: expiryDate!,
                  );
                },
                child: const Text('Generate Discount Card'),
              ),
              const SizedBox(height: 20),
              if (discount != null)
                Screenshot(
                  controller: screenshotController,
                  child: DiscountCard(data: discount),
                ),
              const SizedBox(height: 20),
              if (discount != null)
                ElevatedButton(
                  onPressed: () async {
                    final image = await screenshotController.capture();
                    if (image == null) return;

                    await Permission.storage.request();
                    await Permission.photos.request();

                    final tempDir = await getTemporaryDirectory();
                    final filePath = '${tempDir.path}/discount_card.png';
                    final file = File(filePath);
                    await file.writeAsBytes(image);

                    final result = await ImageGallerySaverPlus.saveFile(file.path);
                    if (result['isSuccess'] == true) {
                      Get.snackbar("Success", "Saved to Gallery");
                    } else {
                      Get.snackbar("Failed", "Could not save image");
                    }
                  },
                  child: const Text('Save as Image'),
                ),
              ElevatedButton(
                onPressed: () => Get.toNamed('/search'),
                child: const Text('Search Discount Card'),
              ),


            ],
          );
        }),
      ),
    );
  }
}
