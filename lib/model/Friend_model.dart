import '../model/event_model.dart';

class Friend {
  final String name;
  final String phoneNumber;
  final String email;
  final int upcomingEvents;
  final String? profilePictureUrl; // Optional now, for backward compatibility
  final String? id;
  final List<EventModel> events = [];// Added Firestore document ID

  Friend({
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.upcomingEvents,
    this.profilePictureUrl,
    this.id,
  });

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      upcomingEvents: map['upcomingEvents'] ?? 0,
      profilePictureUrl: map['profilePictureUrl'],
      id: map['id'], // Store the Firestore document ID
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'upcomingEvents': upcomingEvents,
      'profilePictureUrl': profilePictureUrl,
      // Note: We typically don't include the id in the toMap method
      // as it's managed by Firestore and not stored in the document itself
    };
  }
}
