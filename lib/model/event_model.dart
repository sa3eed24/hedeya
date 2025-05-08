class event_model{
  final String Name;
  final int id;
  final String category;
  final String status;

  event_model({
    required this.Name,
    required this.id,
    required this.category,
    required this.status
  });

  factory event_model.fromJson(Map<String, dynamic> json) {
    return event_model(
      Name: json['Name'],
      id: json['id'],
      category: json['category'],
      status: json['status'],
    );
  }

}