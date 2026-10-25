import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'certificate_fingerprint.dart';

/// Mobile / desktop: reject any server whose certificate is not in [pins].
void installPinning(Dio dio, Set<String> pins) {
  dio.httpClientAdapter = IOHttpClientAdapter(
    validateCertificate: (certificate, host, port) {
      if (certificate == null) return false;
      return matchesPin(certificate.der, pins);
    },
  );
}
