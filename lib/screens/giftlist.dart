import 'package:flutter/material.dart';
import '../model/gift_model.dart';
import '../model/event_model.dart';
import '../utils/giftcard.dart';
import '../screens/addgift.dart';
import '../screens/pledgedgifts.dart';
import '../services/giftcardcontrol.dart';

class GiftList extends StatefulWidget {
  final String eventId;
  final String eventName;

  const GiftList({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<GiftList> createState() => _GiftListState();
}

class _GiftListState extends State<GiftList> {
  int _currentIndex = 0;
  List<GiftModel> _gifts = [];
  bool _isLoading = true;
  final GiftCardControl _giftController = GiftCardControl();

  @override
  void initState() {
    super.initState();
    _loadEventGifts();
  }

  Future<void> _loadEventGifts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final gifts = await _giftController.getEventGifts(widget.eventId);
      setState(() {
        _gifts = gifts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading gifts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onGiftStatusChanged(String giftId, int index, bool status) async {
    // Update locally first for responsive UI
    setState(() {
      _gifts[index] = GiftModel(
        id: _gifts[index].id,
        name: _gifts[index].name,
        description: _gifts[index].description,
        price: _gifts[index].price,
        imageUrl: _gifts[index].imageUrl,
        status: status,
        pledgedUser: status ? 'Current User' : '',
        eventId: _gifts[index].eventId,
      );
    });

    // Then update in Firebase
    await _giftController.updateGiftStatus(
        giftId,
        status,
        status ? 'Current User' : ''
    );
  }

  void _deleteGift(String giftId, int index) async {
    final deletedGift = _gifts[index];

    // Remove locally first
    setState(() {
      _gifts.removeAt(index);
    });

    // Show undo snackbar
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
        duration: const Duration(seconds: 3),
      ),
    );

    // After snackbar duration, if not undone, delete from Firebase
    await Future.delayed(const Duration(seconds: 3, milliseconds: 300));
    if (!_gifts.contains(deletedGift)) {
      await _giftController.deleteGift(giftId);
    }
  }

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
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.white),
              title: const Text('My Events', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/eventlist');
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(widget.eventName),
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
          child: _isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : Column(
            children: [
              Expanded(
                child: _gifts.isEmpty
                    ? Center(
                  child: Text(
                    'No gifts added to this event yet\nTap the + button to add one',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: _loadEventGifts,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    itemCount: _gifts.length,
                    itemBuilder: (context, index) {
                      final gift = _gifts[index];
                      return Dismissible(
                        key: Key(gift.id ?? '${gift.name}_$index'),
                        direction: gift.status
                            ? DismissDirection.none
                            : DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (gift.status) return false;
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Gift'),
                              content: Text(
                                  'Are you sure you want to delete ${gift.name}?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) =>
                            _deleteGift(gift.id ?? 'temp_$index', index),
                        child: GiftCard(
                          gift: gift,
                          onStatusChanged: (status) =>
                              _onGiftStatusChanged(gift.id ?? 'temp_$index', index, status),
                        ),
                      );
                    },
                  ),
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
                builder: (context) => PledgedGifts(
                  gifts: _gifts,
                  eventId: widget.eventId,
                  eventName: widget.eventName,
                ),
              ),
            ).then((_) {
              setState(() {
                _currentIndex = 0;
              });
              _loadEventGifts(); // Refresh gifts when returning from pledged gifts screen
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
          final newGift = await Navigator.push<GiftModel>(
            context,
            MaterialPageRoute(
              builder: (context) => AddGift(eventId: widget.eventId),
            ),
          );

          if (newGift != null && mounted) {
            final success = await _giftController.addGift(newGift);

            if (success) {
              _loadEventGifts(); // Refresh the list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${newGift.name} added successfully!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to add gift. Please try again.')),
              );
            }
          }
        },
        child: const Icon(Icons.add, color: Colors.red),
        backgroundColor: Colors.white,
      )
          : null,
    );
  }
}