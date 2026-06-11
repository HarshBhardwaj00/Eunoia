import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import 'intro_success_screen.dart';
import 'app_lock_screen.dart';
import 'login_screen.dart';

// Authentication guard - manages biometric verification and routing
class AuthGatekeeper extends ConsumerStatefulWidget {
  const AuthGatekeeper({super.key});

  @override
  ConsumerState<AuthGatekeeper> createState() => _AuthGatekeeperState();
}

class _AuthGatekeeperState extends ConsumerState<AuthGatekeeper> {
  bool _biometricUnlocked = false;

  void _onBiometricUnlocked() {
    setState(() {
      _biometricUnlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Step 1: Show AppLockScreen for biometric verification
    if (!_biometricUnlocked) {
      return AppLockScreen(onUnlocked: _onBiometricUnlocked);
    }

    // Step 2: After biometric unlock, watch user profile state
    final userProfile = ref.watch(userProfileProvider);

    // Step 3: If not authenticated (uid is null), route to LoginScreen
    if (userProfile.uid == null) {
      return const LoginScreen();
    }

    // Step 4: If fully authenticated, show IntroSuccessScreen
    return const IntroSuccessScreen();
  }
}
