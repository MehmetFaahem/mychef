import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/recipe_model.dart';
import '../services/ai_service.dart';

class RecipeRepository {
  final AIService _aiService;
  static const String _savedRecipesKey = 'saved_recipes';
  static const String _favoriteRecipesKey = 'favorite_recipes';
  static const String _recentIngredientsKey = 'recent_ingredients';

  RecipeRepository({
    required AIService aiService,
  }) : _aiService = aiService;

  // Recipe Generation
  Future<List<Recipe>> generateRecipes({
    required List<String> ingredients,
    String dietaryPreferences = '',
    String cuisineType = '',
    String difficulty = '',
    int servings = 4,
  }) async {
    try {
      // Save recent ingredients
      await _saveRecentIngredients(ingredients);

      return await _aiService.generateRecipes(
        ingredients: ingredients,
        dietaryPreferences: dietaryPreferences,
        cuisineType: cuisineType,
        difficulty: difficulty,
        servings: servings,
      );
    } catch (e) {
      throw Exception('Failed to generate recipes: $e');
    }
  }

  // Recipe Storage
  Future<void> saveRecipe(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRecipes = await getSavedRecipes();

      final updatedRecipe = recipe.copyWith(isSaved: true);
      final index = savedRecipes.indexWhere((r) => r.id == recipe.id);

      if (index >= 0) {
        savedRecipes[index] = updatedRecipe;
      } else {
        savedRecipes.add(updatedRecipe);
      }

      final jsonList = savedRecipes.map((r) => r.toJson()).toList();
      await prefs.setString(_savedRecipesKey, jsonEncode(jsonList));
    } catch (e) {
      throw Exception('Failed to save recipe: $e');
    }
  }

  Future<void> unsaveRecipe(String recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRecipes = await getSavedRecipes();

      savedRecipes.removeWhere((recipe) => recipe.id == recipeId);

      final jsonList = savedRecipes.map((r) => r.toJson()).toList();
      await prefs.setString(_savedRecipesKey, jsonEncode(jsonList));
    } catch (e) {
      throw Exception('Failed to unsave recipe: $e');
    }
  }

  Future<List<Recipe>> getSavedRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_savedRecipesKey);

      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Favorites
  Future<void> toggleFavorite(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = await _getFavoriteIds();

      if (favoriteIds.contains(recipe.id)) {
        favoriteIds.remove(recipe.id);
      } else {
        favoriteIds.add(recipe.id);
      }

      await prefs.setStringList(_favoriteRecipesKey, favoriteIds.toList());
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  Future<Set<String>> _getFavoriteIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = prefs.getStringList(_favoriteRecipesKey) ?? [];
      return favoritesList.toSet();
    } catch (e) {
      return <String>{};
    }
  }

  Future<bool> isFavorite(String recipeId) async {
    final favoriteIds = await _getFavoriteIds();
    return favoriteIds.contains(recipeId);
  }

  // Recent Ingredients
  Future<void> _saveRecentIngredients(List<String> ingredients) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentIngredients = await getRecentIngredients();

      // Add new ingredients to the beginning, remove duplicates
      final updatedIngredients = <String>[];
      updatedIngredients.addAll(ingredients);

      for (final ingredient in recentIngredients) {
        if (!updatedIngredients.contains(ingredient)) {
          updatedIngredients.add(ingredient);
        }
      }

      // Keep only the most recent 50 ingredients
      final limitedIngredients = updatedIngredients.take(50).toList();

      await prefs.setStringList(_recentIngredientsKey, limitedIngredients);
    } catch (e) {
      // Silently fail for recent ingredients
    }
  }

  Future<List<String>> getRecentIngredients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_recentIngredientsKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  // Recipes Filtering & Search
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final savedRecipes = await getSavedRecipes();
      if (query.isEmpty) return savedRecipes;

      return savedRecipes.where((recipe) {
        return recipe.name.toLowerCase().contains(query.toLowerCase()) ||
            recipe.ingredients.any((ingredient) =>
                ingredient.toLowerCase().contains(query.toLowerCase())) ||
            recipe.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final savedRecipes = await getSavedRecipes();
      if (category.isEmpty) return savedRecipes;

      return savedRecipes.where((recipe) {
        return recipe.tags.any((tag) => tag.toLowerCase() == category.toLowerCase());
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
