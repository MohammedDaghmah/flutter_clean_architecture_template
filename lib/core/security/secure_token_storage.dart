import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the session / auth token lives.
///
/// The app depends on this contract, not on a plugin. Tests use a fake, and
/// the storage mechanism can change without touching callers.
abstract class TokenStorage {
  Future<void> saveToken(String token);
  Future<String?> readToken();
  Future<void> clear();
}

/// Keeps the token in the platform's secure store: the iOS Keychain, or
/// Android's Keystore-backed encrypted preferences. Never use plain
/// SharedPreferences or Hive for credentials: those files are readable on a
/// rooted device and in backups.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  static const tokenKey = 'auth_token';

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveToken(String token) =>
      _storage.write(key: tokenKey, value: token);

  @override
  Future<String?> readToken() => _storage.read(key: tokenKey);

  @override
  Future<void> clear() => _storage.delete(key: tokenKey);
}
