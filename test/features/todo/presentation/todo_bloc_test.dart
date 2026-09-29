import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_architecture_template/core/error/failures.dart';
import 'package:flutter_clean_architecture_template/core/usecase/usecase.dart';
import 'package:flutter_clean_architecture_template/features/todo/domain/entities/todo_entity.dart';
import 'package:flutter_clean_architecture_template/features/todo/domain/usecases/create_todo.dart';
import 'package:flutter_clean_architecture_template/features/todo/domain/usecases/delete_todo.dart';
import 'package:flutter_clean_architecture_template/features/todo/domain/usecases/get_all_todos.dart';
import 'package:flutter_clean_architecture_template/features/todo/presentation/bloc/todo_bloc.dart';

class MockGetAllTodos extends Mock implements GetAllTodos {}

class MockCreateTodo extends Mock implements CreateTodo {}

class MockDeleteTodo extends Mock implements DeleteTodo {}

void main() {
  late MockGetAllTodos getAllTodos;
  late MockCreateTodo createTodo;
  late MockDeleteTodo deleteTodo;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const CreateTodoParams(title: '', description: ''),
    );
    registerFallbackValue(const DeleteTodoParams(''));
  });

  setUp(() {
    getAllTodos = MockGetAllTodos();
    createTodo = MockCreateTodo();
    deleteTodo = MockDeleteTodo();
  });

  TodoBloc buildBloc() => TodoBloc(
        getAllTodos: getAllTodos,
        createTodo: createTodo,
        deleteTodo: deleteTodo,
      );

  final tTodo = TodoEntity(
    id: '1',
    title: 'Buy milk',
    description: '',
    isCompleted: false,
    createdAt: DateTime(2026, 1, 1),
  );

  blocTest<TodoBloc, TodoState>(
    'emits [TodoLoading, TodoLoaded] when LoadTodos succeeds',
    setUp: () {
      when(() => getAllTodos(any())).thenAnswer((_) async => Right([tTodo]));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const LoadTodos()),
    expect: () => [TodoLoading(), TodoLoaded([tTodo])],
  );

  blocTest<TodoBloc, TodoState>(
    'emits [TodoLoading, TodoError] when LoadTodos fails',
    setUp: () {
      when(() => getAllTodos(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Down')));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const LoadTodos()),
    expect: () => [TodoLoading(), const TodoError('Down')],
  );
}
