import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Base64 SHA-256 of a certificate's DER bytes.
///
/// To get the pin for your server:
/// `openssl s_client -connect api.example.com:443 </dev/null 2>/dev/null |
///  openssl x509 -outform der | openssl dgst -sha256 -binary | openssl enc -base64`
String certificateFingerprint(Uint8List derBytes) =>
    base64.encode(sha256.convert(derBytes).bytes);

/// True when the certificate's fingerprint is one of the allowed [pins].
bool matchesPin(Uint8List derBytes, Set<String> pins) =>
    pins.contains(certificateFingerprint(derBytes));
