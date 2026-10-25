import 'package:dio/dio.dart';

/// Web: the browser owns TLS validation, so pinning is not possible here.
void installPinning(Dio dio, Set<String> pins) {}
