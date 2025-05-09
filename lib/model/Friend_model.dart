// lib/model/friend_model.dart
class Friend {
  final String id;
  final String name;
  final String profilePictureUrl;
  final int upcomingEvents;

  Friend({required this.id, required this.name, required this.profilePictureUrl, this.upcomingEvents = 0});

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      name: map['name'],
      profilePictureUrl: map['profilePictureUrl'],
      upcomingEvents: map['upcomingEvents'] ?? 0,
    );
  }
}