import 'package:flutter/material.dart';
import '../model/gift_model.dart';
import '../services/giftcardcontrol.dart';
import '../utils/giftcard.dart';

class PledgedGifts extends StatefulWidget {
  final String eventId;
  final String eventName;

  const PledgedGifts({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<PledgedGifts> createState() => _PledgedGiftsState();
}

class _PledgedGiftsState extends State<PledgedGifts> {
  int _currentIndex = 1;
  List<GiftModel> _pledgedGifts = [];
  bool _isLoading = true;
  final GiftCardControl _giftController = GiftCardControl();

  @override
  void initState() {
    super.initState();
    _loadPledgedGifts();
  }

  Future<void> _loadPledgedGifts() async {
    setState(() => _isLoading = true);
    try {
      final allGifts = await _giftController.getEventGifts(widget.eventId);
      setState(() {
        _pledgedGifts = allGifts.where((gift) => gift.status).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading gifts: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _unpledgeGift(String giftId) async {
    try {
      await _giftController.updateGiftStatus(
        giftId: giftId,
        status: false,
        pledgedUser: null,
      );
      await _loadPledgedGifts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unpledge gift: ${e.toString()}')),
        );
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
        title: Text('${widget.eventName}  - Pledged Gifts'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.deepPurple],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pledgedGifts.isEmpty
              ? const Center(
            child: Text(
              'No pledged gifts yet for this event',
              style: TextStyle(fontSize: 18),
            ),
          )
              : RefreshIndicator(
            onRefresh: _loadPledgedGifts,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _pledgedGifts.length,
              itemBuilder: (context, index) {
                final gift = _pledgedGifts[index];
                return GiftCard(
                  gift: gift,
                  onStatusChanged: (status) {
                    if (!status) _unpledgeGift(gift.id!);
                  },
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          if (index == 0) Navigator.pop(context);
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
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}