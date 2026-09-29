import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_data_source.dart';
import '../datasources/todo_remote_data_source.dart';
import '../models/todo_model.dart';

/// This is the only class that knows about both Dio and Hive. Everything
/// above it (domain, presentation) only ever talks to [TodoRepository].
///
/// Pattern: try remote first when online, fall back to cache on failure or
/// when offline. Every exception from a data source is caught here and
/// converted into a [Failure] — nothing throws past this boundary.
class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;
  final TodoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TodoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<TodoEntity>>> getAllTodos() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTodos = await remoteDataSource.getAllTodos();
        await localDataSource.cacheTodos(remoteTodos);
        return Right(remoteTodos);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final localTodos = await localDataSource.getCachedTodos();
        return Right(localTodos);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, TodoEntity>> getTodoById(String id) async {
    try {
      final todo = await remoteDataSource.getTodoById(id);
      return Right(todo);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TodoEntity>> createTodo(TodoEntity todo) async {
    try {
      final created = await remoteDataSource.createTodo(
        TodoModel.fromEntity(todo),
      );
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TodoEntity>> updateTodo(TodoEntity todo) async {
    try {
      final updated = await remoteDataSource.updateTodo(
        TodoModel.fromEntity(todo),
      );
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTodo(String id) async {
    try {
      await remoteDataSource.deleteTodo(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
