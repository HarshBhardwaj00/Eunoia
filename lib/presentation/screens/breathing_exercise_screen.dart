import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/premium_design_system.dart';
import '../../widgets/premium_button.dart';

// Breathing exercise screen - guided box breathing animation
enum BreathingState { inhale, hold, exhale }

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  BreathingState _currentState = BreathingState.inhale;
  int _countdown = 4;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 150,
      end: 280,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isRunning = true;
      _currentState = BreathingState.inhale;
      _countdown = 4;
    });
    _controller.forward(from: 0);
    _startCountdown();
  }

  void _pauseExercise() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
    _controller.stop();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        _transitionToNextPhase();
      }
    });
  }

  void _transitionToNextPhase() {
    switch (_currentState) {
      case BreathingState.inhale:
        setState(() {
          _currentState = BreathingState.hold;
          _countdown = 4;
        });
        _controller.reset();
        _controller.repeat(reverse: true);
        break;
      case BreathingState.hold:
        setState(() {
          _currentState = BreathingState.exhale;
          _countdown = 4;
        });
        _controller.stop();
        _controller.reverse(from: 1);
        break;
      case BreathingState.exhale:
        setState(() {
          _currentState = BreathingState.inhale;
          _countdown = 4;
        });
        _controller.reset();
        _controller.forward();
        break;
    }
  }

  String _getStatusText() {
    switch (_currentState) {
      case BreathingState.inhale:
        return 'Inhale';
      case BreathingState.hold:
        return 'Hold';
      case BreathingState.exhale:
        return 'Exhale';
    }
  }

  Color _getStatusColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (_currentState) {
      case BreathingState.inhale:
        return theme.colorScheme.primary;
      case BreathingState.hold:
        return theme.colorScheme.secondary;
      case BreathingState.exhale:
        return theme.colorScheme.primary.withOpacity(0.7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final maxCircleSize = screenSize.width * 0.7;
    final minCircleSize = screenSize.width * 0.4;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Box Breathing',
                    style: PremiumDesignSystem.displayMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Circle
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        double scale;
                        if (_currentState == BreathingState.hold) {
                          scale = maxCircleSize * _pulseAnimation.value;
                        } else {
                          scale =
                              minCircleSize +
                              (maxCircleSize - minCircleSize) *
                                  _scaleAnimation.value /
                                  280;
                        }

                        return Container(
                          width: scale,
                          height: scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getStatusColor(context).withOpacity(0.1),
                            border: Border.all(
                              color: _getStatusColor(context),
                              width: PremiumDesignSystem.borderWidth,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getStatusColor(
                                  context,
                                ).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _getStatusText(),
                                  style: PremiumDesignSystem.headline.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '$_countdown',
                                  style: PremiumDesignSystem.displayLarge
                                      .copyWith(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.w300,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                    // Instructions
                    Text(
                      _getInstructions(),
                      textAlign: TextAlign.center,
                      style: PremiumDesignSystem.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Controls
            Padding(
              padding: const EdgeInsets.all(32),
              child: PremiumButton(
                label: _isRunning ? 'Pause' : 'Start',
                onPressed: _isRunning ? _pauseExercise : _startExercise,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInstructions() {
    switch (_currentState) {
      case BreathingState.inhale:
        return 'Breathe in deeply through your nose';
      case BreathingState.hold:
        return 'Hold your breath gently';
      case BreathingState.exhale:
        return 'Release slowly through your mouth';
    }
  }
}
