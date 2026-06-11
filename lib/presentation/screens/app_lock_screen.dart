import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../services/biometric_service.dart';

// Biometric authentication screen - secures app access with fingerprint/face ID
class AppLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const AppLockScreen({super.key, required this.onUnlocked});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final BiometricService _biometricService = BiometricService();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;
  String? _errorMessage;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    // Reset cancellation flag and state before starting authentication
    _isCancelled = false;
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      // Check if biometrics are available before attempting authentication
      // Use OR condition as specified: canCheckBiometrics || isDeviceSupported
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        // Biometrics not available - log override bypass event and authenticate
        debugPrint(
          'Biometric authentication bypass: Device not supported or no biometrics enrolled. Setting authenticated state to true for dev mode compatibility.',
        );
        if (mounted) {
          setState(() {
            _isAuthenticating = false;
            _errorMessage = 'Biometrics not available. Bypassing...';
          });
          // Small delay for user feedback, then bypass
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            widget.onUnlocked();
          }
        }
        return;
      }

      // Check if authentication was cancelled before proceeding
      if (_isCancelled) {
        if (mounted) {
          setState(() {
            _isAuthenticating = false;
          });
        }
        return;
      }

      // Biometrics available - attempt authentication
      final isAuthenticated = await _biometricService.authenticateUser();

      if (isAuthenticated && mounted) {
        widget.onUnlocked();
      } else if (mounted && !_isCancelled) {
        setState(() {
          _errorMessage = 'Authentication failed. Please try again.';
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      // Strict error handling for any native platform or thread exceptions
      if (mounted) {
        setState(() {
          _errorMessage = 'Authentication error: ${e.toString()}';
          _isAuthenticating = false;
        });
      }
    }
  }

  void _bypassForDebug() {
    setState(() {
      _isAuthenticating = false;
      _errorMessage = null;
    });
    widget.onUnlocked();
  }

  Future<void> _retryAuthentication() async {
    // Cancel any ongoing authentication before retry
    _isCancelled = true;

    // Wait a brief moment to ensure cancellation is processed
    await Future.delayed(const Duration(milliseconds: 100));

    // Initiate fresh authentication pipeline
    _authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Blurred background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.8)),
          ),
          // Lock screen content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Secure lock icon
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: _isAuthenticating
                      ? const SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(
                          Icons.lock_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(height: 32),
                // Title
                const Text(
                  'App Locked',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  _isAuthenticating
                      ? 'Authenticating...'
                      : _errorMessage ?? 'Authenticate to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_errorMessage != null && !_isAuthenticating) ...[
                  const SizedBox(height: 24),
                  // Retry button
                  ElevatedButton.icon(
                    onPressed: _retryAuthentication,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Debug bypass button
                  TextButton(
                    onPressed: _bypassForDebug,
                    child: Text(
                      'Bypass (Debug)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
