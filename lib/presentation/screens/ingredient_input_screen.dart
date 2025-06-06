import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'recipe_list_screen.dart';

class IngredientInputScreen extends ConsumerStatefulWidget {
  const IngredientInputScreen({super.key});

  @override
  ConsumerState<IngredientInputScreen> createState() =>
      _IngredientInputScreenState();
}

class _IngredientInputScreenState extends ConsumerState<IngredientInputScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _ingredientController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _generatedRecipesKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _wasGeneratingRecipes = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeState = ref.watch(recipeProvider);
    final preferences = ref.watch(recipePreferencesProvider);

    // Check if recipes were just generated and scroll to them
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_wasGeneratingRecipes && 
          !recipeState.isLoading && 
          recipeState.generatedRecipes.isNotEmpty &&
          recipeState.error == null) {
        _scrollToGeneratedRecipes();
        _wasGeneratingRecipes = false;
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('My Chef AI'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (recipeState.savedRecipes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.bookmark_rounded, size: 28),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipeListScreen(),
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
        children: [
          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
            color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                                Text(
                                  'What\'s in your kitchen?',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add ingredients and let AI create amazing recipes for you',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).primaryColor.withOpacity(0.7),
                                  ),
                                ),
              ],
            ),
          ),
        ],
      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

          // Input Section
          Container(
                  padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                      Text(
                  'Add Ingredients',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3436),
                        ),
                ),
                      const SizedBox(height: 8),
                      Text(
                        'Type ingredients one by one',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ingredientController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                                hintText: 'e.g., tomatoes, chicken, pasta...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                                prefixIcon: Icon(
                                  Icons.add_circle_outline,
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                ),
                          border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                          ),
                                filled: true,
                                fillColor: Colors.grey[50],
                        ),
                              style: const TextStyle(fontSize: 16),
                        onSubmitted: (_) => _addIngredient(),
                      ),
                    ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                      onPressed: _addIngredient,
                              icon: const Icon(Icons.add, color: Colors.white),
                              iconSize: 28,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

                const SizedBox(height: 24),

          // Recent Ingredients
          if (recipeState.recentIngredients.isNotEmpty) ...[
                  Text(
              'Recent Ingredients',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3436),
                    ),
            ),
                  const SizedBox(height: 12),
            SizedBox(
                    height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recipeState.recentIngredients.length,
                itemBuilder: (context, index) {
                  final ingredient = recipeState.recentIngredients[index];
                  final isSelected = recipeState.selectedIngredients.contains(
                    ingredient,
                  );

                  return Padding(
                          padding: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(ingredient),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref
                              .read(recipeProvider.notifier)
                              .addIngredient(ingredient);
                        } else {
                          ref
                              .read(recipeProvider.notifier)
                              .removeIngredient(ingredient);
                        }
                      },
                            selectedColor: Theme.of(context).primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                            elevation: isSelected ? 4 : 2,
                            shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  );
                },
              ),
            ),
                  const SizedBox(height: 24),
          ],

          // Selected Ingredients
          if (recipeState.selectedIngredients.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                      Text(
                        'Selected Ingredients (${recipeState.selectedIngredients.length})',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3436),
                        ),
                ),
                      TextButton.icon(
                  onPressed: () =>
                      ref.read(recipeProvider.notifier).clearIngredients(),
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear All'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                        ),
                ),
              ],
            ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
              children: recipeState.selectedIngredients.map((ingredient) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Chip(
                            label: Text(
                              ingredient,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            deleteIcon: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                  onDeleted: () => ref
                      .read(recipeProvider.notifier)
                      .removeIngredient(ingredient),
                            backgroundColor: Colors.transparent,
                            side: BorderSide.none,
                            elevation: 0,
                          ),
                );
              }).toList(),
            ),
                  ),

                  const SizedBox(height: 32),

            // Recipe Preferences
            _buildPreferencesSection(preferences),

                  const SizedBox(height: 32),

            // Generate Button
                  Container(
              width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
              child: ElevatedButton(
                onPressed: recipeState.isLoading
                    ? null
                    : () => _generateRecipes(preferences),
                style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: recipeState.isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 24,
                                  width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Generating recipes...',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  'Generate AI Recipes',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                          fontWeight: FontWeight.bold,
                                    fontSize: 18,
                        ),
                                ),
                              ],
                      ),
              ),
            ),
          ],

          // Error Display
          if (recipeState.error != null) ...[
                  const SizedBox(height: 24),
            Container(
                    padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        ),
                        const SizedBox(width: 12),
                  Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Error',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                      recipeState.error!,
                      style: const TextStyle(color: Colors.red),
                              ),
                            ],
                    ),
                  ),
                  IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () =>
                        ref.read(recipeProvider.notifier).clearError(),
                  ),
                ],
              ),
            ),
          ],

          // Generated Recipes
          if (recipeState.generatedRecipes.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Container(
                    key: _generatedRecipesKey,
                    child: Text(
                'Generated Recipes',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3436),
                      ),
              ),
                  ),
            const SizedBox(height: 16),
            ...recipeState.generatedRecipes.map((recipe) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RecipeCard(
                  recipe: recipe,
                  onTap: () => _viewRecipe(recipe),
                ),
              );
            }),
          ],
        ],
      ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(RecipePreferences preferences) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.tune,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
            'Recipe Preferences',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildDropdown(
            'Dietary Restrictions',
            preferences.dietaryRestrictions,
            ['', 'Vegetarian', 'Vegan', 'Gluten-Free', 'Keto', 'Paleo'],
            Icons.restaurant_menu,
            (value) => ref.read(recipePreferencesProvider.notifier).state =
                preferences.copyWith(dietaryRestrictions: value),
          ),

          const SizedBox(height: 16),

          _buildDropdown(
            'Cuisine Type',
            preferences.cuisineType,
            [
              '',
              'Italian',
              'Mexican',
              'Asian',
              'Indian',
              'Mediterranean',
              'American',
            ],
            Icons.public,
            (value) => ref.read(recipePreferencesProvider.notifier).state =
                preferences.copyWith(cuisineType: value),
          ),

          const SizedBox(height: 16),

          _buildDropdown(
            'Difficulty',
            preferences.difficulty,
            ['', 'Easy', 'Medium', 'Hard'],
            Icons.bar_chart,
            (value) => ref.read(recipePreferencesProvider.notifier).state =
                preferences.copyWith(difficulty: value),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
            child: Row(
            children: [
                Icon(
                  Icons.group,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Servings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Theme.of(context).primaryColor,
                          inactiveTrackColor: Theme.of(context).primaryColor.withOpacity(0.3),
                          thumbColor: Theme.of(context).primaryColor,
                          overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
                          valueIndicatorColor: Theme.of(context).primaryColor,
                          valueIndicatorTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                child: Slider(
                  value: preferences.servings.toDouble(),
                  min: 1,
                  max: 8,
                  divisions: 7,
                          label: '${preferences.servings} ${preferences.servings == 1 ? 'person' : 'people'}',
                  onChanged: (value) {
                    ref.read(recipePreferencesProvider.notifier).state =
                        preferences.copyWith(servings: value.round());
                  },
                ),
              ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${preferences.servings}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    IconData icon,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
        Text(
          label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          ),
          child: DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
            ),
              filled: true,
              fillColor: Colors.transparent,
          ),
            hint: Text(
              'Select $label',
              style: TextStyle(color: Colors.grey[500]),
            ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option.isEmpty ? null : option,
                child: Text(
                  option.isEmpty ? 'Any' : option,
                  style: TextStyle(
                    color: option.isEmpty ? Colors.grey[600] : const Color(0xFF2D3436),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            );
          }).toList(),
          onChanged: (newValue) => onChanged(newValue ?? ''),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isNotEmpty) {
      ref.read(recipeProvider.notifier).addIngredient(ingredient);
      _ingredientController.clear();
      _focusNode.requestFocus();
    }
  }

  void _generateRecipes(RecipePreferences preferences) {
    _wasGeneratingRecipes = true;
    ref.read(recipeProvider.notifier).generateRecipes(preferences);
  }

  void _scrollToGeneratedRecipes() {
    final keyContext = _generatedRecipesKey.currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _viewRecipe(Recipe recipe) {
    Navigator.pushNamed(context, '/recipe-detail', arguments: recipe);
  }
}
