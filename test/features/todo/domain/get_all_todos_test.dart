import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_architecture_template/core/usecase/usecase.dart';
import 'package:flutter_clean_architecture_template/features/todo/domain/entities/todo_entity.dart';
import 'package:flutter_clean_architecture_template/features/todo/domain/repositories/todo_repository.dart';
import 'package:flutter_clean_architecture_template/features/todo/domain/usecases/get_all_todos.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late GetAllTodos usecase;
  late MockTodoRepository repository;

  setUp(() {
    repository = MockTodoRepository();
    usecase = GetAllTodos(repository);
  });

  final tTodos = [
    TodoEntity(
      id: '1',
      title: 'Buy milk',
      description: 'From the store',
      isCompleted: false,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  test(
    'should get list of todos from the repository, unmodified',
    () async {
      // arrange
      when(() => repository.getAllTodos())
          .thenAnswer((_) async => Right(tTodos));

      // act
      final result = await usecase(const NoParams());

      // assert — the use case is a pure pass-through here; the point of
      // the test is verifying the wiring, not business logic.
      expect(result, Right(tTodos));
      verify(() => repository.getAllTodos()).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
