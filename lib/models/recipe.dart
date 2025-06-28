class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final String userId;
  final DateTime? createdAt;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.userId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients.join(','), // save as comma-separated string
      'user_id': userId,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      ingredients: (map['ingredients'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? [],
      userId: map['user_id'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}
