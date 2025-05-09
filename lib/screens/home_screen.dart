import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedeya/screens/addfriend.dart';
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
            MaterialPageRoute(builder: (context) => const AddFriendScreen())
        ),
        label: const Text('Add Friend'),
        icon: const Icon(Icons.person_add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('friends').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No friends added yet'));
          }

          final friends = snapshot.data!.docs
              .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Add document ID to the data
            return Friend.fromMap(data);
          })
              .toList();

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(friend.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(friend.phoneNumber),
                      Text(friend.email, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: friend.upcomingEvents > 0
                      ? Badge(
                    label: Text(friend.upcomingEvents.toString()),
                    child: const Icon(Icons.event),
                  )
                      : const Icon(Icons.chevron_right),
                  isThreeLine: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GiftList(),
                    ),
                  ),
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