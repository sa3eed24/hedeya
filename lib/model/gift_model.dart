import 'dart:io';

class gift_model {
  final String name;
  final String description;
  final double price;
  final File? imageFile;
  final bool status;
  final String pleged_user;
  final int eventid;

  gift_model({
    required this.name,
    required this.description,
    required this.price,
    this.imageFile,
    required this.status,
    required this.pleged_user,
    required this.eventid,
  });

  factory gift_model.fromJson(Map<String, dynamic> json) {
    return gift_model(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0),
      imageFile: json['imageFile'] != null ? File(json['imageFile']) : null,
      status: json['status'] ?? false,
      pleged_user: json['pleged_user'] ?? '',
      eventid: json['eventid'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageFile': imageFile?.path,
      'status': status,
      'pleged_user': pleged_user,
      'eventid': eventid,
    };
  }
}