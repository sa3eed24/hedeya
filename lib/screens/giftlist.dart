import 'package:flutter/material.dart';
import '../model/gift_model.dart';
import '../utils/giftcard.dart';

class GiftList extends StatefulWidget {
  const GiftList({super.key});

  @override
  State<GiftList> createState() => _GiftListState();
}

class _GiftListState extends State<GiftList> {
  final List<gift_model> _gifts = [
    gift_model(
      name: 'Wireless Headphones',
      description: 'Noise cancelling bluetooth headphones',
      price: 149.99,
      image: 'https://via.placeholder.com/150',
      status: false,
      pleged_user: '',
    ),
    gift_model(
      name: 'Smart Watch',
      description: 'Fitness tracker with heart rate monitor',
      price: 199.99,
      image: 'https://via.placeholder.com/150',
      status: true,
      pleged_user: 'John Doe',
    ),
    gift_model(
      name: 'Coffee Maker',
      description: 'Programmable coffee machine with timer',
      price: 89.99,
      image: 'https://via.placeholder.com/150',
      status: false,
      pleged_user: '',
    ),
    gift_model(
      name: 'Portable Speaker',
      description: 'Waterproof bluetooth speaker',
      price: 79.99,
      image: 'https://via.placeholder.com/150',
      status: false,
      pleged_user: '',
    ),
  ];

  void _onGiftStatusChanged(int index, bool status) {
    setState(() {
      _gifts[index] = gift_model(
        name: _gifts[index].name,
        description: _gifts[index].description,
        price: _gifts[index].price,
        image: _gifts[index].image,
        status: status,
        pleged_user: status ? 'Current User' : '',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Empty Drawer (can be populated later)
      drawer: Drawer(
        child: Container(), // Empty drawer for now
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.redAccent],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Centered title
                    const Center(
                      child: Text(
                        'Event Name',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // Back button (left)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                      ),
                    ),
                    // Menu button (right)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Colors.black, size: 30),
                        onPressed: () {
                          Scaffold.of(context).openDrawer(); // Opens the empty drawer
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // List of gift cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: _gifts.length,
                  itemBuilder: (context, index) {
                    return GiftCard(
                      gift: _gifts[index],
                      onStatusChanged: (status) => _onGiftStatusChanged(index, status),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Floating Action Button (bottom right)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new gift')),
          );
        },
        child: const Icon(Icons.add, color: Colors.red),
        backgroundColor: Colors.white,
      ),
    );
  }
}