import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/todo_entity.dart';

/// Contract only — no implementation detail (Dio, Hive, etc.) leaks here.
/// The domain layer depends on this abstraction; the data layer provides
/// the concrete implementation. This is the Dependency Inversion Principle
/// in practice, and it's what makes the domain layer unit-testable without
/// a network or a database.
abstract class TodoRepository {
  Future<Either<Failure, List<TodoEntity>>> getAllTodos();
  Future<Either<Failure, TodoEntity>> getTodoById(String id);
  Future<Either<Failure, TodoEntity>> createTodo(TodoEntity todo);
  Future<Either<Failure, TodoEntity>> updateTodo(TodoEntity todo);
  Future<Either<Failure, void>> deleteTodo(String id);
}
