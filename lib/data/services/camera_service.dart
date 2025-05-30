import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras!.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _controller!.initialize();
        _isInitialized = true;
      }
    } catch (e) {
      throw Exception('Failed to initialize camera: $e');
    }
  }

  Future<List<String>> scanIngredientsFromCamera() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    try {
      final image = await _controller!.takePicture();
      return await _extractTextFromImage(image.path);
    } catch (e) {
      throw Exception('Failed to scan ingredients: $e');
    }
  }

  Future<List<String>> scanIngredientsFromGallery() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return [];

      return await _extractTextFromImage(image.path);
    } catch (e) {
      throw Exception('Failed to scan ingredients from gallery: $e');
    }
  }

  Future<List<String>> _extractTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer();

      final recognizedText = await textRecognizer.processImage(inputImage);

      // Extract potential ingredients from recognized text
      final ingredients = <String>[];
      final commonIngredients = _getCommonIngredients();

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final text = line.text.toLowerCase().trim();

          // Check if the recognized text matches common ingredients
          for (final ingredient in commonIngredients) {
            if (text.contains(ingredient.toLowerCase()) ||
                ingredient.toLowerCase().contains(text)) {
              if (!ingredients.contains(ingredient)) {
                ingredients.add(ingredient);
              }
            }
          }

          // Also add longer text that might be ingredients
          if (text.length > 2 && text.length < 30) {
            final words = text.split(' ');
            for (final word in words) {
              if (word.length > 2 && _looksLikeIngredient(word)) {
                final capitalizedWord = _capitalizeFirst(word);
                if (!ingredients.contains(capitalizedWord)) {
                  ingredients.add(capitalizedWord);
                }
              }
            }
          }
        }
      }

      await textRecognizer.close();
      return ingredients.take(20).toList(); // Limit to 20 ingredients
    } catch (e) {
      throw Exception('Failed to extract text from image: $e');
    }
  }

  bool _looksLikeIngredient(String word) {
    // Simple heuristic to check if a word looks like an ingredient
    final cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    return cleanWord.length >= 3 &&
        !RegExp(r'\d').hasMatch(cleanWord) &&
        !_isCommonNonFoodWord(cleanWord);
  }

  bool _isCommonNonFoodWord(String word) {
    const nonFoodWords = {
      'the',
      'and',
      'for',
      'with',
      'from',
      'best',
      'fresh',
      'organic',
      'natural',
      'pure',
      'premium',
      'quality',
      'brand',
      'product',
    };
    return nonFoodWords.contains(word.toLowerCase());
  }

  String _capitalizeFirst(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  List<String> _getCommonIngredients() {
    return [
      // Vegetables
      'Tomato', 'Onion', 'Garlic', 'Potato', 'Carrot', 'Broccoli', 'Spinach',
      'Bell Pepper', 'Cucumber', 'Lettuce', 'Mushroom', 'Zucchini', 'Celery',

      // Fruits
      'Apple', 'Banana', 'Orange', 'Lemon', 'Lime', 'Strawberry', 'Blueberry',
      'Avocado', 'Pineapple', 'Mango', 'Grapes', 'Peach', 'Pear',

      // Proteins
      'Chicken', 'Beef', 'Pork', 'Fish', 'Salmon', 'Tuna', 'Shrimp', 'Eggs',
      'Tofu', 'Beans', 'Lentils', 'Chickpeas', 'Turkey', 'Ham',

      // Dairy
      'Milk', 'Cheese', 'Butter', 'Yogurt', 'Cream', 'Mozzarella', 'Parmesan',

      // Grains & Starches
      'Rice', 'Pasta', 'Bread', 'Flour', 'Quinoa', 'Oats', 'Barley',

      // Herbs & Spices
      'Basil', 'Oregano', 'Thyme', 'Rosemary', 'Cilantro', 'Parsley',
      'Salt', 'Pepper', 'Paprika', 'Cumin', 'Cinnamon', 'Ginger',

      // Pantry Items
      'Oil', 'Vinegar', 'Sugar', 'Honey', 'Soy Sauce', 'Olive Oil',
      'Coconut Oil', 'Vanilla', 'Baking Powder', 'Baking Soda',
    ];
  }

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;

  void dispose() {
    _controller?.dispose();
    _isInitialized = false;
  }

  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    final currentCamera = _controller?.description;
    final newCamera = _cameras!.firstWhere(
      (camera) => camera != currentCamera,
      orElse: () => _cameras!.first,
    );

    await _controller?.dispose();
    _controller = CameraController(
      newCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller != null && _isInitialized) {
      await _controller!.setFlashMode(mode);
    }
  }
}
