import 'package:safe_device/safe_device.dart';

/// Detects a rooted (Android) or jailbroken (iOS) device.
abstract class DeviceIntegrityChecker {
  Future<bool> isCompromised();
}

class SafeDeviceIntegrityChecker implements DeviceIntegrityChecker {
  @override
  Future<bool> isCompromised() async {
    try {
      return await SafeDevice.isJailBroken;
    } catch (_) {
      // If the check itself fails we do not lock users out. Detection is one
      // defensive layer, not the only one: the server must still validate
      // every request.
      return false;
    }
  }
}
