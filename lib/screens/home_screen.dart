// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedeya/screens/giftlist.dart';
import 'package:hedeya/screens/addgift.dart';
import '../model/Friend_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('My Gift Wish List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddGift())
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGift())
        ),
        label: const Text('Create Event/List'),
        icon: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('friends').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final friends = snapshot.data!.docs
              .map((doc) => Friend.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(friends[index].profilePictureUrl),
                ),
                title: Text(friends[index].name),
                trailing: friends[index].upcomingEvents > 0
                    ? CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Text(friends[index].upcomingEvents.toString(),
                      style: const TextStyle(color: Colors.white)),
                )
                    : null,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GiftList()
                    )
                ),
              );
            },
          );
        },
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
            child: Text('Gift Wish List'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => Navigator.pushNamed(context, '/profile'),
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
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GiftList())
            ),
          ),
        ],
      ),
    );
  }
}