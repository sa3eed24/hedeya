import '../model/gift_model.dart';
class event_model{
  final String Name;
  final int id;
  final String category;
  final String status;
  final String owner;
  final int owner_id;
  List gifts = [];

  event_model({
    required this.Name,
    required this.id,
    required this.category,
    required this.status,
    required this.owner,
    required this.owner_id,
    required this.gifts,
  });

  factory event_model.fromJson(Map<String, dynamic> json) {
    return event_model(
      Name: json['Name'],
      id: json['id'],
      category: json['category'],
      status: json['status'],
      owner: json['owner'],
      owner_id: json['owner_id'],
      gifts: (json['gifts'] as List<dynamic>).map((gift) => gift_model.fromJson(gift)).toList(),
    );
  }

}