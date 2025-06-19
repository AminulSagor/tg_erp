import 'package:flutter/material.dart';
import '../models/discount_model.dart';

class DiscountCard extends StatelessWidget {
  final DiscountModel data;

  const DiscountCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepOrange),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Dear ${data.customerName},", style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            '${data.amount.toInt()} TAKA OFF',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Card ID: ${data.cardId}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Expires: ${data.expiry.toLocal().toString().split(' ')[0]}'),
          const SizedBox(height: 4),
          const Text('One-time use only', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          const SizedBox(height: 16),
          const Text(
            'Take love from Tri Gardening,\nyour gardening buddy',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
