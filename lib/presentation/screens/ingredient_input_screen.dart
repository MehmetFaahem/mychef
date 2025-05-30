import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../widgets/camera_preview.dart';
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeState = ref.watch(recipeProvider);
    final preferences = ref.watch(recipePreferencesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Chef AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (recipeState.savedRecipes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.bookmark),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipeListScreen(),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.orange,
              tabs: const [
                Tab(icon: Icon(Icons.edit), text: 'Manual Input'),
                Tab(icon: Icon(Icons.camera_alt), text: 'Camera Scan'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildManualInputTab(recipeState, preferences),
                _buildCameraScanTab(recipeState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInputTab(
    RecipeState recipeState,
    RecipePreferences preferences,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Ingredients',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ingredientController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText:
                              'Enter ingredient (e.g., tomatoes, chicken)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.restaurant),
                        ),
                        onSubmitted: (_) => _addIngredient(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addIngredient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Recent Ingredients
          if (recipeState.recentIngredients.isNotEmpty) ...[
            const Text(
              'Recent Ingredients',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recipeState.recentIngredients.length,
                itemBuilder: (context, index) {
                  final ingredient = recipeState.recentIngredients[index];
                  final isSelected = recipeState.selectedIngredients.contains(
                    ingredient,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
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
                      selectedColor: Colors.orange.withOpacity(0.2),
                      checkmarkColor: Colors.orange,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Selected Ingredients
          if (recipeState.selectedIngredients.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selected Ingredients',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(recipeProvider.notifier).clearIngredients(),
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recipeState.selectedIngredients.map((ingredient) {
                return Chip(
                  label: Text(ingredient),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => ref
                      .read(recipeProvider.notifier)
                      .removeIngredient(ingredient),
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  deleteIconColor: Colors.orange,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Recipe Preferences
            _buildPreferencesSection(preferences),

            const SizedBox(height: 24),

            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: recipeState.isLoading
                    ? null
                    : () => _generateRecipes(preferences),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: recipeState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Generate Recipes with AI',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],

          // Error Display
          if (recipeState.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recipeState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        ref.read(recipeProvider.notifier).clearError(),
                  ),
                ],
              ),
            ),
          ],

          // Generated Recipes
          if (recipeState.generatedRecipes.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Generated Recipes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildCameraScanTab(RecipeState recipeState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CameraPreviewWidget(
            onCapture: () {
              if (recipeState.selectedIngredients.isNotEmpty) {
                _tabController.animateTo(0);
              }
            },
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: const Column(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(height: 8),
                Text(
                  'Tips for best results:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Ensure good lighting\n'
                  '• Position ingredients clearly in view\n'
                  '• Avoid shadows and reflections\n'
                  '• Hold camera steady',
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),

          if (recipeState.selectedIngredients.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Ingredients Found:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: recipeState.selectedIngredients.map((ingredient) {
                      return Chip(
                        label: Text(ingredient),
                        backgroundColor: Colors.green.withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _tabController.animateTo(0),
                      child: const Text('Review & Generate Recipes'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(RecipePreferences preferences) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recipe Preferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          _buildDropdown(
            'Dietary Restrictions',
            preferences.dietaryRestrictions,
            ['', 'Vegetarian', 'Vegan', 'Gluten-Free', 'Keto', 'Paleo'],
            (value) => ref.read(recipePreferencesProvider.notifier).state =
                preferences.copyWith(dietaryRestrictions: value),
          ),

          const SizedBox(height: 12),

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
            (value) => ref.read(recipePreferencesProvider.notifier).state =
                preferences.copyWith(cuisineType: value),
          ),

          const SizedBox(height: 12),

          _buildDropdown(
            'Difficulty',
            preferences.difficulty,
            ['', 'Easy', 'Medium', 'Hard'],
            (value) => ref.read(recipePreferencesProvider.notifier).state =
                preferences.copyWith(difficulty: value),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Text('Servings: '),
              const SizedBox(width: 16),
              Expanded(
                child: Slider(
                  value: preferences.servings.toDouble(),
                  min: 1,
                  max: 8,
                  divisions: 7,
                  label: '${preferences.servings}',
                  onChanged: (value) {
                    ref.read(recipePreferencesProvider.notifier).state =
                        preferences.copyWith(servings: value.round());
                  },
                ),
              ),
              Text('${preferences.servings}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          hint: Text('Select $label'),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option.isEmpty ? null : option,
              child: Text(option.isEmpty ? 'Any' : option),
            );
          }).toList(),
          onChanged: (newValue) => onChanged(newValue ?? ''),
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
    ref.read(recipeProvider.notifier).generateRecipes(preferences);
  }

  void _viewRecipe(Recipe recipe) {
    Navigator.pushNamed(context, '/recipe-detail', arguments: recipe);
  }
}
