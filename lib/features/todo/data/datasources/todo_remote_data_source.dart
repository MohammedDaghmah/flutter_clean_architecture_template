import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getAllTodos();
  Future<TodoModel> getTodoById(String id);
  Future<TodoModel> createTodo(TodoModel todo);
  Future<TodoModel> updateTodo(TodoModel todo);
  Future<void> deleteTodo(String id);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final Dio dio;

  TodoRemoteDataSourceImpl(this.dio);

  @override
  Future<List<TodoModel>> getAllTodos() async {
    try {
      final response = await dio.get('/todos');
      final data = response.data as List;
      return data
          .map((json) => TodoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException {
      throw const ServerException('Failed to fetch todos.');
    }
  }

  @override
  Future<TodoModel> getTodoById(String id) async {
    try {
      final response = await dio.get('/todos/$id');
      return TodoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      throw const ServerException('Failed to fetch todo.');
    }
  }

  @override
  Future<TodoModel> createTodo(TodoModel todo) async {
    try {
      final response = await dio.post('/todos', data: todo.toJson());
      return TodoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      throw const ServerException('Failed to create todo.');
    }
  }

  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    try {
      final response = await dio.put('/todos/${todo.id}', data: todo.toJson());
      return TodoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      throw const ServerException('Failed to update todo.');
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      await dio.delete('/todos/$id');
    } on DioException {
      throw const ServerException('Failed to delete todo.');
    }
  }
}
