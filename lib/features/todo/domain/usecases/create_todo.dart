import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class CreateTodo implements UseCase<TodoEntity, CreateTodoParams> {
  final TodoRepository repository;

  CreateTodo(this.repository);

  @override
  Future<Either<Failure, TodoEntity>> call(CreateTodoParams params) {
    if (params.title.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Title cannot be empty.')),
      );
    }
    return repository.createTodo(
      TodoEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: params.title,
        description: params.description,
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
    );
  }
}

class CreateTodoParams extends Equatable {
  final String title;
  final String description;

  const CreateTodoParams({required this.title, required this.description});

  @override
  List<Object?> get props => [title, description];
}
