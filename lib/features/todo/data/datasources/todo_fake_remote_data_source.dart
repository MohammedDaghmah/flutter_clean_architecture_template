import '../../../../core/error/exceptions.dart';
import '../models/todo_model.dart';
import 'todo_remote_data_source.dart';

/// In-memory stand-in for a real backend, so the template runs out of the
/// box with no server. It implements the exact same [TodoRemoteDataSource]
/// contract as the Dio implementation — which is the point: swapping one
/// for the other is a one-line change in `injection_container.dart`, and
/// nothing in the domain or presentation layers is aware of it.
class TodoFakeRemoteDataSource implements TodoRemoteDataSource {
  final List<TodoModel> _todos = [
    TodoModel(
      id: '1',
      title: 'Read the README',
      description: 'Understand the layers and the dependency rule.',
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    TodoModel(
      id: '2',
      title: 'Run the tests',
      description: 'flutter test — domain, data, and presentation.',
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
  ];

  Future<void> _simulateLatency() =>
      Future.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<TodoModel>> getAllTodos() async {
    await _simulateLatency();
    return List<TodoModel>.from(_todos);
  }

  @override
  Future<TodoModel> getTodoById(String id) async {
    await _simulateLatency();
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) throw const ServerException('Todo not found.');
    return _todos[index];
  }

  @override
  Future<TodoModel> createTodo(TodoModel todo) async {
    await _simulateLatency();
    _todos.add(todo);
    return todo;
  }

  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    await _simulateLatency();
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index == -1) throw const ServerException('Todo not found.');
    _todos[index] = todo;
    return todo;
  }

  @override
  Future<void> deleteTodo(String id) async {
    await _simulateLatency();
    _todos.removeWhere((t) => t.id == id);
  }
}
