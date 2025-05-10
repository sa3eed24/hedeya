class GiftModel {
  final String? id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final bool status;
  final String pledgedUser;
  final String eventId;

  GiftModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.status,
    required this.pledgedUser,
    required this.eventId,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return GiftModel(
      id: id ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0),
      imageUrl: json['imageUrl'],
      status: json['status'] ?? false,
      pledgedUser: json['pledgedUser'] ?? '',
      eventId: json['eventId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'status': status,
      'pledgedUser': pledgedUser,
      'eventId': eventId,
    };
  }
}