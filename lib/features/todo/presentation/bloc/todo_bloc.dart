import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/usecases/create_todo.dart';
import '../../domain/usecases/delete_todo.dart';
import '../../domain/usecases/get_all_todos.dart';

part 'todo_event.dart';
part 'todo_state.dart';

/// The BLoC only knows about use cases — never about Dio, Hive, or any
/// repository implementation detail. Each event handler follows the same
/// shape: call a use case, `fold` the Either into a Failure or success
/// state. Swapping this for Cubit, Riverpod, or Provider later would only
/// touch this file — the domain and data layers stay untouched.
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetAllTodos getAllTodos;
  final CreateTodo createTodo;
  final DeleteTodo deleteTodo;

  TodoBloc({
    required this.getAllTodos,
    required this.createTodo,
    required this.deleteTodo,
  }) : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<RemoveTodo>(_onRemoveTodo);
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    final result = await getAllTodos(const NoParams());
    result.fold(
      (failure) => emit(TodoError(failure.message)),
      (todos) => emit(TodoLoaded(todos)),
    );
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    final result = await createTodo(
      CreateTodoParams(title: event.title, description: event.description),
    );
    result.fold(
      (failure) => emit(TodoError(failure.message)),
      (_) => add(const LoadTodos()),
    );
  }

  Future<void> _onRemoveTodo(RemoveTodo event, Emitter<TodoState> emit) async {
    final result = await deleteTodo(DeleteTodoParams(event.id));
    result.fold(
      (failure) => emit(TodoError(failure.message)),
      (_) => add(const LoadTodos()),
    );
  }
}
