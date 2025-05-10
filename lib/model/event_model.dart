import '../model/gift_model.dart';
import '../model/user_model.dart';

class EventModel {
  final String name;
  final String id;
  final String category;
  final String status;
  final String owner;
  final List<GiftModel> gifts;
  final List<UserModel> users;

  EventModel({
    required this.name,
    required this.id,
    required this.category,
    required this.status,
    required this.owner,
    required this.gifts,
    required this.users,
  });

  factory EventModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return EventModel(
      name: json['name'] ?? '',
      id: id ?? json['id'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 'active',
      owner: json['owner'] ?? '',
      gifts: (json['gifts'] as List<dynamic>?)
          ?.map((gift) => GiftModel.fromJson(gift))
          .toList() ??
          [],
      users: (json['users'] as List<dynamic>?)
          ?.map((user) => UserModel.fromJson(user))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'category': category,
      'status': status,
      'owner': owner,
      'gifts': gifts.map((gift) => gift.toJson()).toList(),
      'users': users.map((user) => user.toJson()).toList(),
    };
  }
}
