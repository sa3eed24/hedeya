import 'package:flutter/material.dart';
import '../model/gift_model.dart';
import '../utils/giftcard.dart';

class PledgedGifts extends StatelessWidget {
  final List<gift_model> gifts;

  const PledgedGifts({super.key, required this.gifts});

  @override
  Widget build(BuildContext context) {
    final pledgedGifts = gifts.where((gift) => gift.status).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pledged Gifts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: pledgedGifts.isEmpty
          ? const Center(
        child: Text(
          'No pledged gifts yet',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          return GiftCard(
            gift: pledgedGifts[index],
            // Either make onStatusChanged optional in GiftCard or provide a dummy function
            onStatusChanged: (status) {
              // This won't do anything but satisfies the non-null requirement
              // Alternatively, make the parameter nullable in GiftCard
            },
          );
        },
      ),
    );
  }
}