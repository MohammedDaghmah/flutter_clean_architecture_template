import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Every use case implements this contract: given [Params], it returns
/// either a [Failure] or a [T] result. This uniformity is what lets the
/// BLoC layer call any use case the same way, and what makes each use case
/// trivially mockable in tests.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use for use cases that take no parameters (e.g. `GetAllTodos`).
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
