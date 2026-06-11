import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

// Brand introduction screen with fade animation and auto-transition
class IntroSuccessScreen extends StatefulWidget {
  const IntroSuccessScreen({super.key});

  @override
  State<IntroSuccessScreen> createState() => _IntroSuccessScreenState();
}

class _IntroSuccessScreenState extends State<IntroSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();

    // Auto-transition to home screen after 2.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115), // Deep-slate dark theme
      body: Center(
        child: AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(scale: _scaleAnimation, child: child),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Brand Name
              Text(
                'Eunoia',
                style: TextStyle(
                  fontSize: 42.0,
                  letterSpacing: 4.0,
                  fontWeight: FontWeight.w300,
                  color: theme.colorScheme.onSurface,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              const SizedBox(height: 16),
              // Tagline
              Text(
                'Your journey to a beautiful mind.',
                style: TextStyle(
                  fontSize: 16.0,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontFamily: 'SF Pro Text',
                ),
              ),
              const SizedBox(height: 48),
              // Subtle circular progress indicator
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
