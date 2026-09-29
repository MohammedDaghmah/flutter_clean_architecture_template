import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getCachedTodos();
  Future<void> cacheTodos(List<TodoModel> todos);
}

/// Caching the last-known-good list of todos means the app still shows
/// something useful when [NetworkInfo.isConnected] is false, instead of
/// an empty screen or a spinner that never resolves.
class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  static const String boxName = 'todos_cache';
  final Box<Map> box;

  TodoLocalDataSourceImpl(this.box);

  @override
  Future<List<TodoModel>> getCachedTodos() async {
    final raw = box.get('all');
    if (raw == null) {
      throw const CacheException('No cached todos found.');
    }
    final list = (raw['items'] as List)
        .map((item) => TodoModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    return list;
  }

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    await box.put('all', {
      'items': todos.map((t) => t.toJson()).toList(),
    });
  }
}
