import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Wish List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.redAccent],
          ),
        ),
        child: ListView(
          children: [
            _buildWishItem(title: 'Smart Watch', isFulfilled: true),
            _buildWishItem(title: 'Book', isFulfilled: false),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildWishItem({required String title, required bool isFulfilled}) {
    return Card(
      child: ListTile(
        leading: Icon(
          isFulfilled ? Icons.check : Icons.card_giftcard,
          color: isFulfilled ? Colors.green : Colors.red,
        ),
        title: Text(title),
        trailing: IconButton(
          icon: Icon(isFulfilled ? Icons.check_circle : Icons.radio_button_unchecked),
          onPressed: () {},
        ),
      ),
    );
  }
}