import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_clean_architecture_template/core/security/certificate_fingerprint.dart';

void main() {
  final der = Uint8List.fromList([1, 2, 3]);

  // Base64 of SHA-256([1, 2, 3]), computed independently of the code under test.
  const expected = 'A5BYxvLAy0ksUzsKTRTvd8wPeKvMztUofYShogEc+4E=';

  test('certificateFingerprint is the base64 SHA-256 of the DER bytes', () {
    expect(certificateFingerprint(der), expected);
  });

  test('matchesPin accepts a certificate whose fingerprint is pinned', () {
    expect(matchesPin(der, {'other-pin', expected}), isTrue);
  });

  test('matchesPin rejects a certificate that is not pinned', () {
    expect(matchesPin(der, {'other-pin'}), isFalse);
    expect(matchesPin(der, <String>{}), isFalse);
  });
}
