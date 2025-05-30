class Recipe {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String imageUrl;
  final String category;
  final DateTime createdAt;
  final int likes;
  final List<String> savedBy;

  Recipe({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.category,
    required this.createdAt,
    required this.likes,
    required this.savedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'imageUrl': imageUrl,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'savedBy': savedBy,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients']),
      steps: List<String>.from(json['steps']),
      imageUrl: json['imageUrl'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'],
      savedBy: List<String>.from(json['savedBy']),
    );
  }
}
