part of 'todo_bloc.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodos extends TodoEvent {
  const LoadTodos();
}

class AddTodo extends TodoEvent {
  final String title;
  final String description;

  const AddTodo({required this.title, required this.description});

  @override
  List<Object?> get props => [title, description];
}

class RemoveTodo extends TodoEvent {
  final String id;

  const RemoveTodo(this.id);

  @override
  List<Object?> get props => [id];
}
