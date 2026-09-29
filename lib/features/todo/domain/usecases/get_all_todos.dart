import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

/// One class, one business action. This makes the BLoC's job trivial
/// (call the use case, map the result to a state) and makes each action
/// independently unit-testable and mockable.
class GetAllTodos implements UseCase<List<TodoEntity>, NoParams> {
  final TodoRepository repository;

  GetAllTodos(this.repository);

  @override
  Future<Either<Failure, List<TodoEntity>>> call(NoParams params) {
    return repository.getAllTodos();
  }
}
