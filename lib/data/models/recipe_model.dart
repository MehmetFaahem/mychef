import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'recipe_model.g.dart';

@JsonSerializable()
class Recipe {
  final String id;
  final String name;
  final List<String> ingredients;
  final List<RecipeStep> steps;
  final String? imageUrl;
  final int? prepTime;
  final int? cookTime;
  final String? difficulty;
  final List<String> tags;
  bool isSaved;
  bool isFavorite;
  final DateTime createdAt;

  Recipe({
    String? id,
    required this.name,
    required this.ingredients,
    required this.steps,
    this.imageUrl,
    this.prepTime,
    this.cookTime,
    this.difficulty,
    this.tags = const [],
    this.isSaved = false,
    this.isFavorite = false,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeToJson(this);

  Recipe copyWith({
    String? name,
    List<String>? ingredients,
    List<RecipeStep>? steps,
    String? imageUrl,
    int? prepTime,
    int? cookTime,
    String? difficulty,
    List<String>? tags,
    bool? isSaved,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id,
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      imageUrl: imageUrl ?? this.imageUrl,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      isSaved: isSaved ?? this.isSaved,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }

  int get totalTime => (prepTime ?? 0) + (cookTime ?? 0);
}

@JsonSerializable()
class RecipeStep {
  final String description;
  final int? duration; // in minutes
  final String? imageUrl;
  final List<String> tips;
  final String? temperature;

  RecipeStep({
    required this.description,
    this.duration,
    this.imageUrl,
    this.tips = const [],
    this.temperature,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) =>
      _$RecipeStepFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeStepToJson(this);
}

@JsonSerializable()
class Ingredient {
  final String name;
  final String? quantity;
  final String? unit;
  final bool isOptional;

  Ingredient({
    required this.name,
    this.quantity,
    this.unit,
    this.isOptional = false,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientToJson(this);

  @override
  String toString() {
    if (quantity != null && unit != null) {
      return '$quantity $unit $name';
    } else if (quantity != null) {
      return '$quantity $name';
    }
    return name;
  }
}
