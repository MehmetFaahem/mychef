import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/recipe_model.dart';
import '../services/ai_service.dart';
import '../services/camera_service.dart';

class RecipeRepository {
  final AIService _aiService;
  final CameraService _cameraService;
  static const String _savedRecipesKey = 'saved_recipes';
  static const String _favoriteRecipesKey = 'favorite_recipes';
  static const String _recentIngredientsKey = 'recent_ingredients';

  RecipeRepository({
    required AIService aiService,
    required CameraService cameraService,
  }) : _aiService = aiService,
       _cameraService = cameraService;

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

  // Camera-based ingredient recognition
  Future<List<String>> scanIngredientsFromCamera() async {
    try {
      final ingredients = await _cameraService.scanIngredientsFromCamera();
      await _enhanceIngredientsWithAI(ingredients);
      return ingredients;
    } catch (e) {
      throw Exception('Failed to scan ingredients from camera: $e');
    }
  }

  Future<List<String>> scanIngredientsFromGallery() async {
    try {
      final ingredients = await _cameraService.scanIngredientsFromGallery();
      await _enhanceIngredientsWithAI(ingredients);
      return ingredients;
    } catch (e) {
      throw Exception('Failed to scan ingredients from gallery: $e');
    }
  }

  Future<List<String>> _enhanceIngredientsWithAI(
    List<String> scannedIngredients,
  ) async {
    try {
      final text = scannedIngredients.join(' ');
      final enhancedIngredients = await _aiService.identifyIngredientsFromText(
        text,
      );

      // Merge and deduplicate
      final allIngredients = <String>{};
      allIngredients.addAll(scannedIngredients);
      allIngredients.addAll(enhancedIngredients);

      return allIngredients.toList();
    } catch (e) {
      return scannedIngredients; // Return original if AI enhancement fails
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

  // Recipe Search & Filtering
  Future<List<Recipe>> searchRecipes(String query) async {
    final savedRecipes = await getSavedRecipes();

    if (query.isEmpty) return savedRecipes;

    final lowercaseQuery = query.toLowerCase();
    return savedRecipes.where((recipe) {
      return recipe.name.toLowerCase().contains(lowercaseQuery) ||
          recipe.ingredients.any(
            (ingredient) => ingredient.toLowerCase().contains(lowercaseQuery),
          ) ||
          recipe.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  Future<List<Recipe>> filterRecipesByDifficulty(String difficulty) async {
    final savedRecipes = await getSavedRecipes();

    if (difficulty.isEmpty) return savedRecipes;

    return savedRecipes
        .where(
          (recipe) =>
              recipe.difficulty?.toLowerCase() == difficulty.toLowerCase(),
        )
        .toList();
  }

  Future<List<Recipe>> filterRecipesByTime(int maxMinutes) async {
    final savedRecipes = await getSavedRecipes();

    return savedRecipes
        .where((recipe) => recipe.totalTime <= maxMinutes)
        .toList();
  }

  // AI Suggestions
  Future<String> getRecipeSuggestion({
    required String mood,
    required String weather,
    required int timeAvailable,
  }) async {
    return await _aiService.getRecipeSuggestion(
      mood: mood,
      weather: weather,
      timeAvailable: timeAvailable,
    );
  }

  // Camera Control
  Future<void> initializeCamera() async {
    await _cameraService.initialize();
  }

  void disposeCamera() {
    _cameraService.dispose();
  }

  bool get isCameraInitialized => _cameraService.isInitialized;

  Future<void> switchCamera() async {
    await _cameraService.switchCamera();
  }

  // Clear Data
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedRecipesKey);
      await prefs.remove(_favoriteRecipesKey);
      await prefs.remove(_recentIngredientsKey);
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }
}
