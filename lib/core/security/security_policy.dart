import 'package:equatable/equatable.dart';

/// Every security decision of the app in one immutable value object.
///
/// One place to read, one place to change, and one object to inject. No
/// feature reads a global flag or hard-codes its own rule.
class SecurityPolicy extends Equatable {
  const SecurityPolicy({
    this.blockCompromisedDevices = false,
    this.requireBiometricUnlock = false,
    this.certificatePins = const <String>{},
  });

  /// Refuse to run on a rooted / jailbroken device.
  final bool blockCompromisedDevices;

  /// Ask for fingerprint / face before showing the app.
  final bool requireBiometricUnlock;

  /// Allowed server certificate fingerprints (base64 SHA-256). Empty means
  /// normal TLS validation with no pinning.
  final Set<String> certificatePins;

  @override
  List<Object?> get props => [
        blockCompromisedDevices,
        requireBiometricUnlock,
        certificatePins,
      ];
}
