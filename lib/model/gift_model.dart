class GiftModel {
  String? id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final bool status;
  final String pledgedUser;
  final String eventId;
  final String userId; // Added userId field

  GiftModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.status,
    required this.pledgedUser,
    required this.eventId,
    required this.userId,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return GiftModel(
      id: id ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0),
      image: json['imageUrl'],
      status: json['status'] ?? false,
      pledgedUser: json['pledgedUser'] ?? '',
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '', // Added userId field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': image,
      'status': status,
      'pledgedUser': pledgedUser,
      'eventId': eventId,
      'userId': userId, // Added userId field
    };
  }

  GiftModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? image,
    bool? status,
    String? pledgedUser,
    String? eventId,
    String? userId,
  }) {
    return GiftModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      status: status ?? this.status,
      pledgedUser: pledgedUser ?? this.pledgedUser,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId, // Added userId field
    );
  }
}