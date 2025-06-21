import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/discount_model.dart';

class DiscountCard extends StatelessWidget {
  final DiscountModel data;

  const DiscountCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 400,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage(
            'assets/bg.png',
          ), // Background with white section included
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              "Dear ${data.customerName},",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            //const Spacer(),
            const SizedBox(height: 20),
            const Text(
              "DISCOUNT",
              style: TextStyle(color: Color(0xFF1B4F29), letterSpacing: 1.5),
            ),
            const Divider(
              thickness: 1,
              color: Colors.grey,
              indent: 3,
              endIndent: 3,
            ),
            // const SizedBox(height: 8),
            Transform.translate(
              offset: const Offset(0, -5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.amount.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4F29),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(height: 8),
                      Text(
                        "TAKA",
                        style: TextStyle(fontSize: 16, color: Color(0xFF1B4F29)),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -5), // Negative Y moves it up
                        child: Text(
                          "OFF",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF1B4F29),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            Transform.translate(
              offset: const Offset(0, -10), // Move the whole block 10 pixels up
              child: Column(
                children: [
                  Text(
                    "CARD ID: ${data.cardId}",
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1B4F29)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "One-time use only",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1B4F29),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Expires: ${DateFormat('d MMM y').format(data.expiry)}",
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1B4F29)),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18,),
            const Text(
              "Take love from Tri Gardening\nYour gardening buddy",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
