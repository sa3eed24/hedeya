import 'package:flutter/material.dart';
import '../model/gift_model.dart';
import '../utils/giftcard.dart';
import '../screens/addgift.dart';
import 'dart:io';

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
      status: false,
      pleged_user: '',
    ),
    gift_model(
      name: 'Smart Watch',
      description: 'Fitness tracker with heart rate monitor',
      price: 199.99,
      status: true,
      pleged_user: 'John Doe',
    ),
  ];

  void _onGiftStatusChanged(int index, bool status) {
    setState(() {
      _gifts[index] = gift_model(
        name: _gifts[index].name,
        description: _gifts[index].description,
        price: _gifts[index].price,
        imageFile: _gifts[index].imageFile,
        status: status,
        pleged_user: status ? 'Current User' : '',
      );
    });
  }

  void _deleteGift(int index) {
    final deletedGift = _gifts[index];
    setState(() {
      _gifts.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted ${deletedGift.name}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _gifts.insert(index, deletedGift);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
              child: Text(
                'Gift Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
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
                    const Center(
                      child: Text(
                        'Gift Registry',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Colors.black, size: 30),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _gifts.isEmpty
                    ? Center(
                  child: Text(
                    'No gifts added yet\nTap the + button to add one',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: _gifts.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(_gifts[index].name + index.toString()),
                      direction: _gifts[index].status
                          ? DismissDirection.none
                          : DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (_gifts[index].status) return false;
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Gift'),
                            content: Text('Are you sure you want to delete ${_gifts[index].name}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) => _deleteGift(index),
                      child: GiftCard(
                        gift: _gifts[index],
                        onStatusChanged: (status) => _onGiftStatusChanged(index, status),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newGift = await Navigator.push<gift_model>(
            context,
            MaterialPageRoute(
              builder: (context) => AddGift(),
            ),
          );

          if (newGift != null && mounted) {
            setState(() {
              _gifts.add(newGift);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${newGift.name} added successfully!')),
            );
          }
        },
        child: const Icon(Icons.add, color: Colors.red),
        backgroundColor: Colors.white,
      ),
    );
  }
}