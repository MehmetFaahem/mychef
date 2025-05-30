import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recipe_provider.dart';

class StepTimer extends ConsumerStatefulWidget {
  final int? duration; // Duration in minutes
  final bool autoStart;
  final VoidCallback? onTimerComplete;

  const StepTimer({
    super.key,
    this.duration,
    this.autoStart = false,
    this.onTimerComplete,
  });

  @override
  ConsumerState<StepTimer> createState() => _StepTimerState();
}

class _StepTimerState extends ConsumerState<StepTimer>
    with TickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: Duration(
        seconds: widget.duration != null ? widget.duration! * 60 : 0,
      ),
      vsync: this,
    );

    if (widget.autoStart && widget.duration != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTimer();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cookingState = ref.watch(cookingProvider);

    if (widget.duration == null) {
      return const SizedBox.shrink();
    }

    final isRunning = cookingState.isTimerRunning;
    final remainingSeconds = cookingState.remainingSeconds;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Timer Display
          Stack(
            alignment: Alignment.center,
            children: [
              // Progress Ring
              SizedBox(
                width: 200,
                height: 200,
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: _progressController.value,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getTimerColor(remainingSeconds),
                      ),
                    );
                  },
                ),
              ),

              // Timer Text
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isRunning
                        ? 1.0 + (_pulseController.value * 0.05)
                        : 1.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(remainingSeconds),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: _getTimerColor(remainingSeconds),
                          ),
                        ),
                        Text(
                          isRunning ? 'Running' : 'Paused',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Reset Button
              _buildControlButton(
                icon: Icons.refresh,
                label: 'Reset',
                onPressed: _resetTimer,
                color: Colors.grey,
              ),

              // Play/Pause Button
              _buildControlButton(
                icon: isRunning ? Icons.pause : Icons.play_arrow,
                label: isRunning ? 'Pause' : 'Start',
                onPressed: isRunning ? _pauseTimer : _startTimer,
                color: Colors.orange,
                isPrimary: true,
              ),

              // Skip Button
              _buildControlButton(
                icon: Icons.skip_next,
                label: 'Skip',
                onPressed: _skipTimer,
                color: Colors.blue,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress Bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressController.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getTimerColor(remainingSeconds),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Time Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0:00',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                _formatTime(widget.duration! * 60),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        Container(
          width: isPrimary ? 64 : 48,
          height: isPrimary ? 64 : 48,
          decoration: BoxDecoration(
            color: isPrimary ? color : color.withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: isPrimary ? Colors.white : color,
              size: isPrimary ? 28 : 24,
            ),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _startTimer() {
    final cookingNotifier = ref.read(cookingProvider.notifier);
    cookingNotifier.startTimer();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = ref.read(cookingProvider);
      final newSeconds = currentState.remainingSeconds - 1;

      if (newSeconds <= 0) {
        _completeTimer();
      } else {
        cookingNotifier.updateTimer(newSeconds);
        _updateProgress(newSeconds);
      }
    });

    _pulseController.repeat(reverse: true);
  }

  void _pauseTimer() {
    final cookingNotifier = ref.read(cookingProvider.notifier);
    cookingNotifier.pauseTimer();

    _timer?.cancel();
    _pulseController.stop();
  }

  void _resetTimer() {
    final cookingNotifier = ref.read(cookingProvider.notifier);
    cookingNotifier.resetTimer();

    _timer?.cancel();
    _pulseController.reset();
    _progressController.reset();
  }

  void _skipTimer() {
    _completeTimer();
  }

  void _completeTimer() {
    final cookingNotifier = ref.read(cookingProvider.notifier);
    cookingNotifier.updateTimer(0);

    _timer?.cancel();
    _pulseController.stop();
    _progressController.forward();

    widget.onTimerComplete?.call();

    // Show completion feedback
    _showTimerComplete();
  }

  void _updateProgress(int remainingSeconds) {
    if (widget.duration != null) {
      final totalSeconds = widget.duration! * 60;
      final progress = (totalSeconds - remainingSeconds) / totalSeconds;
      _progressController.value = progress;
    }
  }

  void _showTimerComplete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timer Complete!'),
        content: const Text('Time\'s up for this step.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor(int remainingSeconds) {
    if (remainingSeconds <= 30) {
      return Colors.red;
    } else if (remainingSeconds <= 120) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}

// Simple Timer Widget for quick use
class SimpleTimer extends StatelessWidget {
  final int seconds;
  final bool isActive;
  final VoidCallback onStart;
  final VoidCallback onPause;

  const SimpleTimer({
    super.key,
    required this.seconds,
    required this.isActive,
    required this.onStart,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getTimerColor(seconds),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: Icon(isActive ? Icons.pause : Icons.play_arrow),
            label: Text(isActive ? 'Pause' : 'Start'),
            onPressed: isActive ? onPause : onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimerColor(int seconds) {
    if (seconds <= 30) {
      return Colors.red;
    } else if (seconds <= 120) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
