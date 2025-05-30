class UserModel {
  final String id;
  final String name;
  final String email;
  final String profileImage;
  final List<String> followers;
  final List<String> following;
  final List<String> savedRecipes;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.followers,
    required this.following,
    required this.savedRecipes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'followers': followers,
      'following': following,
      'savedRecipes': savedRecipes,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      followers: List<String>.from(json['followers']),
      following: List<String>.from(json['following']),
      savedRecipes: List<String>.from(json['savedRecipes']),
    );
  }
}
