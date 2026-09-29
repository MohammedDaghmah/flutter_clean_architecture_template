import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_architecture_template/core/error/exceptions.dart';
import 'package:flutter_clean_architecture_template/core/error/failures.dart';
import 'package:flutter_clean_architecture_template/core/network/network_info.dart';
import 'package:flutter_clean_architecture_template/features/todo/data/datasources/todo_local_data_source.dart';
import 'package:flutter_clean_architecture_template/features/todo/data/datasources/todo_remote_data_source.dart';
import 'package:flutter_clean_architecture_template/features/todo/data/models/todo_model.dart';
import 'package:flutter_clean_architecture_template/features/todo/data/repositories/todo_repository_impl.dart';

class MockRemoteDataSource extends Mock implements TodoRemoteDataSource {}

class MockLocalDataSource extends Mock implements TodoLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late TodoRepositoryImpl repository;
  late MockRemoteDataSource remoteDataSource;
  late MockLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;

  setUpAll(() {
    registerFallbackValue(<TodoModel>[]);
  });

  setUp(() {
    remoteDataSource = MockRemoteDataSource();
    localDataSource = MockLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = TodoRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
  });

  final tTodoModel = TodoModel(
    id: '1',
    title: 'Buy milk',
    description: 'From the store',
    isCompleted: false,
    createdAt: DateTime(2026, 1, 1),
  );

  group('getAllTodos — online', () {
    setUp(() {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    });

    test('fetches from remote, caches it, and returns it', () async {
      when(() => remoteDataSource.getAllTodos())
          .thenAnswer((_) async => [tTodoModel]);
      when(() => localDataSource.cacheTodos(any())).thenAnswer((_) async {});

      final result = await repository.getAllTodos();

      verify(() => remoteDataSource.getAllTodos()).called(1);
      verify(() => localDataSource.cacheTodos([tTodoModel])).called(1);
      expect(result, Right<Failure, List<TodoModel>>([tTodoModel]));
    });

    test('returns ServerFailure when the remote call throws', () async {
      when(() => remoteDataSource.getAllTodos())
          .thenThrow(const ServerException('Down'));

      final result = await repository.getAllTodos();

      expect(result, const Left<Failure, List<TodoModel>>(ServerFailure('Down')));
      verifyZeroInteractions(localDataSource);
    });
  });

  group('getAllTodos — offline', () {
    setUp(() {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
    });

    test('falls back to the cache and never touches the remote source',
        () async {
      when(() => localDataSource.getCachedTodos())
          .thenAnswer((_) async => [tTodoModel]);

      final result = await repository.getAllTodos();

      verifyZeroInteractions(remoteDataSource);
      expect(result, Right<Failure, List<TodoModel>>([tTodoModel]));
    });

    test('returns CacheFailure when nothing is cached', () async {
      when(() => localDataSource.getCachedTodos())
          .thenThrow(const CacheException('Empty'));

      final result = await repository.getAllTodos();

      expect(result, const Left<Failure, List<TodoModel>>(CacheFailure('Empty')));
    });
  });
}
