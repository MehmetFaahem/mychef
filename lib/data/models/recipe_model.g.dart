// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
  id: json['id'] as String?,
  name: json['name'] as String,
  ingredients: (json['ingredients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  steps: (json['steps'] as List<dynamic>)
      .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
      .toList(),
  imageUrl: json['imageUrl'] as String?,
  prepTime: (json['prepTime'] as num?)?.toInt(),
  cookTime: (json['cookTime'] as num?)?.toInt(),
  difficulty: json['difficulty'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isSaved: json['isSaved'] as bool? ?? false,
  isFavorite: json['isFavorite'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'ingredients': instance.ingredients,
  'steps': instance.steps,
  'imageUrl': instance.imageUrl,
  'prepTime': instance.prepTime,
  'cookTime': instance.cookTime,
  'difficulty': instance.difficulty,
  'tags': instance.tags,
  'isSaved': instance.isSaved,
  'isFavorite': instance.isFavorite,
  'createdAt': instance.createdAt.toIso8601String(),
};

RecipeStep _$RecipeStepFromJson(Map<String, dynamic> json) => RecipeStep(
  description: json['description'] as String,
  duration: (json['duration'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
  tips:
      (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  temperature: json['temperature'] as String?,
);

Map<String, dynamic> _$RecipeStepToJson(RecipeStep instance) =>
    <String, dynamic>{
      'description': instance.description,
      'duration': instance.duration,
      'imageUrl': instance.imageUrl,
      'tips': instance.tips,
      'temperature': instance.temperature,
    };

Ingredient _$IngredientFromJson(Map<String, dynamic> json) => Ingredient(
  name: json['name'] as String,
  quantity: json['quantity'] as String?,
  unit: json['unit'] as String?,
  isOptional: json['isOptional'] as bool? ?? false,
);

Map<String, dynamic> _$IngredientToJson(Ingredient instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'isOptional': instance.isOptional,
    };
