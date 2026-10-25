import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../security/certificate_pinning.dart';

/// Centralized Dio configuration. Keeping this in one place means every
/// feature's remote data source shares the same base URL, timeouts,
/// headers, TLS pinning, and logging behavior instead of re-configuring Dio
/// per feature.
class DioClient {
  static Dio create({
    required String baseUrl,
    Set<String> certificatePins = const <String>{},
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    applyCertificatePinning(dio, certificatePins);

    // Request and response bodies can contain tokens and personal data, so
    // they are only logged in debug builds.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }
}
