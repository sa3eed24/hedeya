import 'package:flutter/material.dart';
import '../model/gift_model.dart';
import '../screens/addgift.dart';
import '../screens/pledgedgifts.dart';
import '../services/giftcardcontrol.dart';
import '../utils/giftcard.dart';

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
    setState(() => _isLoading = true);
    try {
      final gifts = await _giftController.getEventGifts(widget.eventId);
      setState(() => _gifts = gifts);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading gifts: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onGiftStatusChanged(String giftId, int index, bool status) async {
    final previousState = _gifts[index];
    try {
      setState(() {
        _gifts[index] = _gifts[index].copyWith(
          status: status,
          pledgedUser: status ? 'Current User' : null,
        );
      });

      await _giftController.updateGiftStatus(
        giftId: giftId,
        status: status,
        pledgedUser: status ? 'Current User' : null,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update gift: ${e.toString()}')),
        );
        setState(() => _gifts[index] = previousState);
      }
    }
  }

  Future<void> _deleteGift(String giftId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deleting gift...'), duration: Duration(seconds: 1)),
    );

    try {
      debugPrint('[DEBUG] Deleting gift with ID: $giftId');
      await _giftController.deleteGift(giftId);

      setState(() {
        _gifts.removeWhere((gift) => gift.id == giftId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gift deleted successfully!')),
        );
      }
    } catch (e) {
      debugPrint('[DEBUG] Error in GiftList._deleteGift: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete gift: $e')),
        );
        _loadEventGifts();
      }
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
              ? const Center(child: CircularProgressIndicator())
              : _gifts.isEmpty
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
                  key: Key(gift.id!),
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
                            'Are you sure you want to delete ${gift.name}?\n\nGift ID: ${gift.id}'),
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
                  onDismissed: (direction) => _deleteGift(gift.id!),
                  child: GiftCard(
                    gift: gift,
                    onStatusChanged: (status) =>
                        _onGiftStatusChanged(gift.id!, index, status),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PledgedGifts(
                  eventId: widget.eventId,
                  eventName: widget.eventName,
                ),
              ),
            ).then((_) {
              if (mounted) {
                setState(() => _currentIndex = 0);
                _loadEventGifts();
              }
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
            try {
              await _giftController.addGift(newGift);
              _loadEventGifts();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('${newGift.name} added successfully!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Failed to add gift: ${e.toString()}')),
              );
            }
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.redAccent,
      )
          : null,
    );
  }
}