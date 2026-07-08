class Exercise {
  final int exerciseId;
  final String name;
  final String category;
  final String description;
  final bool isActive;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.category,
    required this.description,
    required this.isActive,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exercise_id'],
      name: json['name'],
      category: json['category'] ?? "",
      description: json['description'] ?? "",
      isActive: json['is_active'] ?? true,
    );
  }
}