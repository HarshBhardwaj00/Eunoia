import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Authenticate user using biometrics (fingerprint, face ID, etc.)
  /// Returns true if authentication succeeds, false otherwise
  Future<bool> authenticateUser() async {
    try {
      // Check if device supports biometric authentication
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) {
        return false;
      }

      // Check if biometrics are available on the device
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        return false;
      }

      // Trigger biometric authentication prompt with sticky options to prevent thread lock
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to view your private journals',
        biometricOnly: false, // Allows device PIN fallback if sensor is busy
        persistAcrossBackgrounding:
            true, // Prevents authentication from failing if app goes to background briefly
      );

      return didAuthenticate;
    } catch (e) {
      // Handle various authentication errors
      return false;
    }
  }

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      return isSupported && canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Get list of available biometric types on the device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
}
