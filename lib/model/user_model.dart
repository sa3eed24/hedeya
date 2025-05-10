class UserModel {
  final String Name;
  final String Email;
  final String password;
  final String image;

  UserModel({
    required this.Name,
    required this.Email,
    required this.password,
    required this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      Name: json['Name'],
      Email: json['Email'],
      password: json['password'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': Name,
      'Email': Email,
      'password': password,
      'image': image,
    };
  }

}