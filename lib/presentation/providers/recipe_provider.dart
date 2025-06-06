import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/recipe_model.dart';
import '../../data/services/ai_service.dart';
import '../../data/repositories/recipe_repository.dart';

// Service Providers
final aiServiceProvider = Provider<AIService>((ref) => AIService());

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository(
    aiService: ref.watch(aiServiceProvider),
  );
});

// State Models
class RecipeState {
  final List<Recipe> generatedRecipes;
  final List<Recipe> savedRecipes;
  final List<String> selectedIngredients;
  final List<String> recentIngredients;
  final bool isLoading;
  final String? error;

  const RecipeState({
    this.generatedRecipes = const [],
    this.savedRecipes = const [],
    this.selectedIngredients = const [],
    this.recentIngredients = const [],
    this.isLoading = false,
    this.error,
  });

  RecipeState copyWith({
    List<Recipe>? generatedRecipes,
    List<Recipe>? savedRecipes,
    List<String>? selectedIngredients,
    List<String>? recentIngredients,
    bool? isLoading,
    String? error,
  }) {
    return RecipeState(
      generatedRecipes: generatedRecipes ?? this.generatedRecipes,
      savedRecipes: savedRecipes ?? this.savedRecipes,
      selectedIngredients: selectedIngredients ?? this.selectedIngredients,
      recentIngredients: recentIngredients ?? this.recentIngredients,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RecipePreferences {
  final String dietaryRestrictions;
  final String cuisineType;
  final String difficulty;
  final int servings;

  const RecipePreferences({
    this.dietaryRestrictions = '',
    this.cuisineType = '',
    this.difficulty = '',
    this.servings = 4,
  });

  RecipePreferences copyWith({
    String? dietaryRestrictions,
    String? cuisineType,
    String? difficulty,
    int? servings,
  }) {
    return RecipePreferences(
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      cuisineType: cuisineType ?? this.cuisineType,
      difficulty: difficulty ?? this.difficulty,
      servings: servings ?? this.servings,
    );
  }
}

// Main Recipe Provider
class RecipeNotifier extends StateNotifier<RecipeState> {
  final RecipeRepository _repository;

  RecipeNotifier(this._repository) : super(const RecipeState()) {
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final savedRecipes = await _repository.getSavedRecipes();
      final recentIngredients = await _repository.getRecentIngredients();

      state = state.copyWith(
        savedRecipes: savedRecipes,
        recentIngredients: recentIngredients,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Ingredient Management
  void addIngredient(String ingredient) {
    if (!state.selectedIngredients.contains(ingredient)) {
      state = state.copyWith(
        selectedIngredients: [...state.selectedIngredients, ingredient],
      );
    }
  }

  void removeIngredient(String ingredient) {
    state = state.copyWith(
      selectedIngredients: state.selectedIngredients
          .where((i) => i != ingredient)
          .toList(),
    );
  }

  void clearIngredients() {
    state = state.copyWith(selectedIngredients: []);
  }

  void setIngredients(List<String> ingredients) {
    state = state.copyWith(selectedIngredients: ingredients);
  }

  // Recipe Generation
  Future<void> generateRecipes(RecipePreferences preferences) async {
    if (state.selectedIngredients.isEmpty) {
      state = state.copyWith(error: 'Please select some ingredients first');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final recipes = await _repository.generateRecipes(
        ingredients: state.selectedIngredients,
        dietaryPreferences: preferences.dietaryRestrictions,
        cuisineType: preferences.cuisineType,
        difficulty: preferences.difficulty,
        servings: preferences.servings,
      );

      state = state.copyWith(generatedRecipes: recipes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Recipe Management
  Future<void> saveRecipe(Recipe recipe) async {
    try {
      await _repository.saveRecipe(recipe);
      final savedRecipes = await _repository.getSavedRecipes();
      state = state.copyWith(savedRecipes: savedRecipes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> unsaveRecipe(String recipeId) async {
    try {
      await _repository.unsaveRecipe(recipeId);
      final savedRecipes = await _repository.getSavedRecipes();
      state = state.copyWith(savedRecipes: savedRecipes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    try {
      await _repository.toggleFavorite(recipe);
      final savedRecipes = await _repository.getSavedRecipes();
      state = state.copyWith(savedRecipes: savedRecipes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

final recipeProvider = StateNotifierProvider<RecipeNotifier, RecipeState>((
  ref,
) {
  return RecipeNotifier(ref.watch(recipeRepositoryProvider));
});

// Recipe Preferences Provider
final recipePreferencesProvider = StateProvider<RecipePreferences>((ref) {
  return const RecipePreferences();
});

// Cooking State Provider
class CookingState {
  final Recipe? currentRecipe;
  final int currentStepIndex;
  final bool isTimerRunning;
  final int remainingSeconds;
  final bool isCompleted;

  const CookingState({
    this.currentRecipe,
    this.currentStepIndex = 0,
    this.isTimerRunning = false,
    this.remainingSeconds = 0,
    this.isCompleted = false,
  });

  CookingState copyWith({
    Recipe? currentRecipe,
    int? currentStepIndex,
    bool? isTimerRunning,
    int? remainingSeconds,
    bool? isCompleted,
  }) {
    return CookingState(
      currentRecipe: currentRecipe ?? this.currentRecipe,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  RecipeStep? get currentStep {
    if (currentRecipe == null ||
        currentStepIndex >= currentRecipe!.steps.length) {
      return null;
    }
    return currentRecipe!.steps[currentStepIndex];
  }

  bool get hasNextStep =>
      currentRecipe != null &&
      currentStepIndex < currentRecipe!.steps.length - 1;

  bool get hasPreviousStep => currentStepIndex > 0;
}

class CookingNotifier extends StateNotifier<CookingState> {
  CookingNotifier() : super(const CookingState());

  void startCooking(Recipe recipe) {
    state = CookingState(
      currentRecipe: recipe,
      currentStepIndex: 0,
      remainingSeconds: recipe.steps.first.duration != null
          ? recipe.steps.first.duration! * 60
          : 0,
    );
  }

  void nextStep() {
    if (state.hasNextStep) {
      final nextIndex = state.currentStepIndex + 1;
      final nextStep = state.currentRecipe!.steps[nextIndex];

      state = state.copyWith(
        currentStepIndex: nextIndex,
        isTimerRunning: false,
        remainingSeconds: nextStep.duration != null
            ? nextStep.duration! * 60
            : 0,
        isCompleted: nextIndex >= state.currentRecipe!.steps.length - 1,
      );
    }
  }

  void previousStep() {
    if (state.hasPreviousStep) {
      final prevIndex = state.currentStepIndex - 1;
      final prevStep = state.currentRecipe!.steps[prevIndex];

      state = state.copyWith(
        currentStepIndex: prevIndex,
        isTimerRunning: false,
        remainingSeconds: prevStep.duration != null
            ? prevStep.duration! * 60
            : 0,
        isCompleted: false,
      );
    }
  }

  void startTimer() {
    state = state.copyWith(isTimerRunning: true);
  }

  void pauseTimer() {
    state = state.copyWith(isTimerRunning: false);
  }

  void updateTimer(int seconds) {
    state = state.copyWith(remainingSeconds: seconds);

    if (seconds <= 0) {
      state = state.copyWith(isTimerRunning: false);
    }
  }

  void resetTimer() {
    final currentStep = state.currentStep;
    state = state.copyWith(
      isTimerRunning: false,
      remainingSeconds: currentStep?.duration != null
          ? currentStep!.duration! * 60
          : 0,
    );
  }

  void stopCooking() {
    state = const CookingState();
  }
}

final cookingProvider = StateNotifierProvider<CookingNotifier, CookingState>((
  ref,
) {
  return CookingNotifier();
});

// Search Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredSavedRecipesProvider = Provider<List<Recipe>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final recipes = ref.watch(recipeProvider).savedRecipes;

  if (query.isEmpty) return recipes;

  final lowercaseQuery = query.toLowerCase();
  return recipes.where((recipe) {
    return recipe.name.toLowerCase().contains(lowercaseQuery) ||
        recipe.ingredients.any(
          (ingredient) => ingredient.toLowerCase().contains(lowercaseQuery),
        ) ||
        recipe.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
  }).toList();
});
