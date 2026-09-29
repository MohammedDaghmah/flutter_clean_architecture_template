/// Exceptions live in the data layer. They get caught in the repository
/// implementation and translated into [Failure]s before crossing into the
/// domain layer — the domain layer should never see a raw exception.
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);
}
