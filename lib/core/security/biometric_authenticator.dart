import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Biometric (fingerprint / face) authentication behind a small contract.
abstract class BiometricAuthenticator {
  /// True when the device supports biometrics and at least one is enrolled.
  Future<bool> isAvailable();

  /// Shows the system biometric prompt. Returns true only on success.
  Future<bool> authenticate({required String reason});
}

class LocalAuthBiometricAuthenticator implements BiometricAuthenticator {
  LocalAuthBiometricAuthenticator({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      // Not enrolled, locked out, or the user cancelled: treat as "no".
      return false;
    }
  }
}
