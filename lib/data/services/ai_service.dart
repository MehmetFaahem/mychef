import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/recipe_model.dart';

class AIService {
  static const String _apiKey =
      'AIzaSyB-jknLQyovqkYLFYHdV9RvnmNU9Gurb70'; // Replace with actual API key
  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        maxOutputTokens: 2000,
      ),
    );
  }

  Future<List<Recipe>> generateRecipes({
    required List<String> ingredients,
    String dietaryPreferences = '',
    String cuisineType = '',
    String difficulty = '',
    int servings = 4,
  }) async {
    try {
      final prompt = _buildRecipePrompt(
        ingredients: ingredients,
        dietaryPreferences: dietaryPreferences,
        cuisineType: cuisineType,
        difficulty: difficulty,
        servings: servings,
      );

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from AI service');
      }

      return _parseRecipeResponse(responseText);
    } catch (e) {
      throw Exception('Failed to generate recipes: $e');
    }
  }

  Future<List<String>> identifyIngredientsFromText(String text) async {
    try {
      final prompt =
          '''
      Extract food ingredients from this text and return them as a JSON array of strings.
      Only include actual food ingredients, not cooking tools or methods.
      Text: "$text"
      
      Return format: {"ingredients": ["ingredient1", "ingredient2", ...]}
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        return [];
      }

      final jsonData = jsonDecode(responseText);
      return List<String>.from(jsonData['ingredients'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<String> getRecipeSuggestion({
    required String mood,
    required String weather,
    required int timeAvailable,
  }) async {
    try {
      final prompt =
          '''
      Suggest a type of recipe based on:
      - Mood: $mood
      - Weather: $weather  
      - Time available: $timeAvailable minutes
      
      Return just the recipe type/cuisine suggestion as a single sentence.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Try making something simple and delicious!';
    } catch (e) {
      return 'Try making something simple and delicious!';
    }
  }

  String _buildRecipePrompt({
    required List<String> ingredients,
    required String dietaryPreferences,
    required String cuisineType,
    required String difficulty,
    required int servings,
  }) {
    return '''
    You are a world-class chef and recipe expert. Create 3 diverse and delicious recipes using these ingredients: ${ingredients.join(', ')}.

    Requirements:
    - Use ONLY the provided ingredients (you can suggest optional common pantry items)
    - Servings: $servings people
    ${dietaryPreferences.isNotEmpty ? '- Dietary preferences: $dietaryPreferences' : ''}
    ${cuisineType.isNotEmpty ? '- Cuisine type: $cuisineType' : ''}
    ${difficulty.isNotEmpty ? '- Difficulty level: $difficulty' : ''}

    Return in this EXACT JSON format:
    {
      "recipes": [
        {
          "name": "Recipe Name",
          "ingredients": ["ingredient 1", "ingredient 2"],
          "steps": [
            {
              "description": "Detailed step description",
              "duration": 5,
              "tips": ["helpful tip"],
              "temperature": "180°C"
            }
          ],
          "prepTime": 15,
          "cookTime": 30,
          "difficulty": "Easy",
          "tags": ["tag1", "tag2"]
        }
      ]
    }

    Make the recipes creative, detailed, and practical. Include cooking times, temperatures, and helpful tips.
    ''';
  }

  List<Recipe> _parseRecipeResponse(String response) {
    try {
      // Clean up the response text
      String cleanResponse = response.trim();

      // Find JSON boundaries
      int start = cleanResponse.indexOf('{');
      int end = cleanResponse.lastIndexOf('}') + 1;

      if (start == -1 || end <= start) {
        throw Exception('No valid JSON found in response');
      }

      String jsonString = cleanResponse.substring(start, end);
      final jsonData = jsonDecode(jsonString);

      final recipesJson = jsonData['recipes'] as List?;
      if (recipesJson == null || recipesJson.isEmpty) {
        throw Exception('No recipes found in response');
      }

      return recipesJson.map((recipeJson) {
        // Convert the AI response format to our Recipe model
        final steps =
            (recipeJson['steps'] as List?)?.map((stepJson) {
              return RecipeStep(
                description: stepJson['description'] ?? '',
                duration: stepJson['duration']?.toInt(),
                tips: stepJson['tips'] != null
                    ? List<String>.from(stepJson['tips'])
                    : [],
                temperature: stepJson['temperature'],
              );
            }).toList() ??
            [];

        return Recipe(
          name: recipeJson['name'] ?? 'Untitled Recipe',
          ingredients: recipeJson['ingredients'] != null
              ? List<String>.from(recipeJson['ingredients'])
              : [],
          steps: steps,
          prepTime: recipeJson['prepTime']?.toInt(),
          cookTime: recipeJson['cookTime']?.toInt(),
          difficulty: recipeJson['difficulty'],
          tags: recipeJson['tags'] != null
              ? List<String>.from(recipeJson['tags'])
              : [],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }
}
