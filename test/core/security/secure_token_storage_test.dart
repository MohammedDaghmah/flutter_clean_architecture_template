import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_architecture_template/core/security/secure_token_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage storage;
  late SecureTokenStorage tokenStorage;

  setUp(() {
    storage = MockFlutterSecureStorage();
    tokenStorage = SecureTokenStorage(storage: storage);
  });

  test('saveToken writes the token under the token key', () async {
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});

    await tokenStorage.saveToken('abc');

    verify(
      () => storage.write(key: SecureTokenStorage.tokenKey, value: 'abc'),
    ).called(1);
  });

  test('readToken returns what the secure store holds', () async {
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => 'abc');

    expect(await tokenStorage.readToken(), 'abc');
  });

  test('clear deletes the token key', () async {
    when(() => storage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});

    await tokenStorage.clear();

    verify(() => storage.delete(key: SecureTokenStorage.tokenKey)).called(1);
  });
}
