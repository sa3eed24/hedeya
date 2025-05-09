import 'package:flutter/material.dart';
import '../model/gift_model.dart';
import '../utils/giftcard.dart';
import '../screens/addgift.dart';
import '../screens/pledgedgifts.dart';

class GiftList extends StatefulWidget {
  const GiftList({super.key});

  @override
  State<GiftList> createState() => _GiftListState();
}

class _GiftListState extends State<GiftList> {
  int _currentIndex = 0;
  final List<gift_model> _gifts = [
    gift_model(
        name: 'Wireless Headphones',
        description: 'Noise cancelling bluetooth headphones',
        price: 149.99,
        status: false,
        pleged_user: '',
        eventid: 0
    ),
    gift_model(
        name: 'Smart Watch',
        description: 'Fitness tracker with heart rate monitor',
        price: 199.99,
        status: true,
        pleged_user: 'John Doe',
        eventid: 0
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
        eventid: _gifts[index].eventid,
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.pink,
            ),
            child: Text(
              'Gift Wish List',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pushNamed(context, '/home'),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('My Wishlist'),
            onTap: () => Navigator.pushNamed(context, '/giftlist'),
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Friends'),
            onTap: () => Navigator.pushNamed(context, '/friends'),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add Gift'),
            onTap: () async {
              Navigator.pop(context); // Close the drawer first
              final newGift = await Navigator.push<gift_model>(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddGift(),
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return false;
      },
      child: Scaffold(
        drawer: _buildDrawer(context),
        appBar: AppBar(
          title: const Text('Gift Registry'),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.redAccent],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
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
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (_gifts[index].status) return false;
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Gift'),
                              content: Text('Are you sure you want to delete ${_gifts[index].name}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PledgedGifts(gifts: _gifts),
                ),
              ).then((_) {
                setState(() {
                  _currentIndex = 0;
                });
              });
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard),
              label: 'All Gifts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user),
              label: 'Pledged Gifts',
            ),
          ],
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.grey,
        ),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
          onPressed: () async {
            final newGift = await Navigator.push<gift_model>(
              context,
              MaterialPageRoute(
                builder: (context) => const AddGift(),
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
        )
            : null,
      ),
    );
  }
}