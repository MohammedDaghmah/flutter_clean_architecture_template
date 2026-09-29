import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures.
///
/// Failures are returned (never thrown) from repositories and use cases,
/// wrapped in `Either<Failure, T>`. This keeps error handling explicit and
/// forces every call site to handle both the success and failure paths.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No cached data available.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
