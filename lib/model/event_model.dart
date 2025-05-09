import '../model/gift_model.dart';
import '../model/user_model.dart';
class event_model{
  final String Name;
  final int id;
  final String category;
  final String status;
  final String owner;
  List gifts = [];
  List users = [];

  event_model({
    required this.Name,
    required this.id,
    required this.category,
    required this.status,
    required this.owner,
    required this.gifts,
    required this.users,
  });

  factory event_model.fromJson(Map<String, dynamic> json) {
    return event_model(
      Name: json['Name'],
      id: json['id'],
      category: json['category'],
      status: json['status'],
      owner: json['owner'],
      gifts: (json['gifts'] as List<dynamic>).map((gift) => gift_model.fromJson(gift)).toList(),
      users: (json['users'] as List<dynamic>).map((user) => User_model.fromJson(user)).toList(),
    );
  }

}