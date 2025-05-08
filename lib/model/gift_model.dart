class gift_model {
  final String name;
  final String description;
  final double price;
  final String image;
  final bool status;
  final String pleged_user;

  gift_model({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.status,
    required this.pleged_user,
  });

  factory gift_model.fromJson(Map<String, dynamic> json) {
    return gift_model(
      name: json['name'],
      description: json['description'],
      price: json['price'],
      image: json['image'],
      status: json['status'],
      pleged_user: json['pleged_user'],
    );
  }

}