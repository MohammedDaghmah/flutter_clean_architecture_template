import 'package:dio/dio.dart';

import 'certificate_pinning_stub.dart'
    if (dart.library.io) 'certificate_pinning_io.dart' as platform;

/// Certificate pinning for [dio]: only servers whose certificate fingerprint
/// is in [pins] are trusted, even if a rogue CA signed another certificate.
/// An empty set leaves normal TLS validation untouched.
///
/// Always ship at least two pins (current + backup) so a certificate renewal
/// does not lock every installed app out.
void applyCertificatePinning(Dio dio, Set<String> pins) {
  if (pins.isEmpty) return;
  platform.installPinning(dio, pins);
}
