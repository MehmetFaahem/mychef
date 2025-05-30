import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../widgets/step_timer.dart';

class CookingScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const CookingScreen({super.key, required this.recipe});

  @override
  ConsumerState<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends ConsumerState<CookingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressAnimation = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start cooking session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cookingProvider.notifier).startCooking(widget.recipe);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cookingState = ref.watch(cookingProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.recipe.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _exitCooking(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${cookingState.currentStepIndex + 1} of ${widget.recipe.steps.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (cookingState.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Complete!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value:
                      (cookingState.currentStepIndex + 1) /
                      widget.recipe.steps.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.orange,
                  ),
                  minHeight: 6,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                if (index < cookingState.currentStepIndex) {
                  ref.read(cookingProvider.notifier).previousStep();
                } else if (index > cookingState.currentStepIndex) {
                  ref.read(cookingProvider.notifier).nextStep();
                }
              },
              itemCount: widget.recipe.steps.length,
              itemBuilder: (context, index) {
                final step = widget.recipe.steps[index];
                return _buildStepContent(step, index);
              },
            ),
          ),

          // Navigation Controls
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Previous Button
                if (cookingState.hasPreviousStep)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _previousStep(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                if (cookingState.hasPreviousStep && cookingState.hasNextStep)
                  const SizedBox(width: 16),

                // Next/Complete Button
                if (cookingState.hasNextStep)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _nextStep(),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next Step'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _completeCooking(),
                      icon: const Icon(Icons.check),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  Widget _buildStepContent(RecipeStep step, int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Step ${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Step Description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                  'Instructions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  step.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),

                // Temperature info
                if (step.temperature != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.thermostat,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Temperature: ${step.temperature}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Tips
                if (step.tips.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Tips:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...step.tips.map((tip) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 8, right: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Timer Section
          if (step.duration != null) ...[
            const Text(
              'Timer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StepTimer(
              duration: step.duration,
              onTimerComplete: () {
                _showTimerCompleteDialog();
              },
            ),
          ],
        ],
      ),
    );
  }

  void _previousStep() {
    ref.read(cookingProvider.notifier).previousStep();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextStep() {
    ref.read(cookingProvider.notifier).nextStep();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _completeCooking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recipe Complete! 🎉'),
        content: Text(
          'Congratulations! You\'ve completed "${widget.recipe.name}". '
          'Would you like to save this recipe?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exitCooking();
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(recipeProvider.notifier).saveRecipe(widget.recipe);
              Navigator.of(context).pop();
              _exitCooking();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recipe saved!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Recipe'),
          ),
        ],
      ),
    );
  }

  void _exitCooking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Cooking?'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(cookingProvider.notifier).stopCooking();
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close cooking screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _showTimerCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⏰ Timer Complete!'),
        content: const Text(
          'The timer for this step has finished. Ready for the next step?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Stay on Step'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (ref.read(cookingProvider).hasNextStep) {
                _nextStep();
              }
            },
            child: const Text('Next Step'),
          ),
        ],
      ),
    );
  }
}
