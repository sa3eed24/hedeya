class Friend {
  final String name;
  final String phoneNumber;
  final String email;
  final int upcomingEvents;
  final String? profilePictureUrl; // Optional now, for backward compatibility

  Friend({
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.upcomingEvents,
    this.profilePictureUrl,
  });

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      upcomingEvents: map['upcomingEvents'] ?? 0,
      profilePictureUrl: map['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'upcomingEvents': upcomingEvents,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}