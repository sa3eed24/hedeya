class User_model {
  final String Name;
  final String Email;
  final String password;
  final String image;

  User_model({
    required this.Name,
    required this.Email,
    required this.password,
    required this.image,
  });

  factory User_model.fromJson(Map<String, dynamic> json) {
    return User_model(
      Name: json['Name'],
      Email: json['Email'],
      password: json['password'],
      image: json['image'],
    );
  }

}