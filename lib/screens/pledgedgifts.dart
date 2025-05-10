import 'package:flutter/material.dart';
import '../model/gift_model.dart';
import '../utils/giftcard.dart';
import '../screens/giftlist.dart';

class PledgedGifts extends StatefulWidget {
  final List<gift_model> gifts;

  const PledgedGifts({super.key, required this.gifts});

  @override
  State<PledgedGifts> createState() => _PledgedGiftsState();
}

class _PledgedGiftsState extends State<PledgedGifts> {
  int _currentIndex = 1;

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink, Colors.red],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Gift Wish List',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.white),
              title: const Text('My Wishlist', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/giftlist');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.white),
              title: const Text('Friends', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/friends');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.white),
              title: const Text('Add Gift', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GiftList()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pledgedGifts = widget.gifts.where((gift) => gift.status).toList();

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return false;
      },
      child: Scaffold(
        drawer: _buildDrawer(context),
        appBar: AppBar(
          title: const Text('Pledged Gifts'),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.deepPurple], // Changed to purple background
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: pledgedGifts.isEmpty
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
                        onStatusChanged: (status) {
                          // Empty callback for pledged view
                        },
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
            if (index == _currentIndex) return;

            setState(() {
              _currentIndex = index;
            });

            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GiftList(),
                ),
              );
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
          selectedItemColor: Colors.purple, // Changed to match the new background gradient
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }
}