import 'package:dio/dio.dart';

/// Centralized Dio configuration. Keeping this in one place means every
/// feature's remote data source shares the same base URL, timeouts,
/// headers, and logging behavior instead of re-configuring Dio per feature.
class DioClient {
  static Dio create({required String baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        // Swap for a no-op logger in release builds.
      ),
    );

    return dio;
  }
}
