import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/todo/data/datasources/todo_fake_remote_data_source.dart';
import '../../features/todo/data/datasources/todo_local_data_source.dart';
import '../../features/todo/data/datasources/todo_remote_data_source.dart';
import '../../features/todo/data/repositories/todo_repository_impl.dart';
import '../../features/todo/domain/repositories/todo_repository.dart';
import '../../features/todo/domain/usecases/create_todo.dart';
import '../../features/todo/domain/usecases/delete_todo.dart';
import '../../features/todo/domain/usecases/get_all_todos.dart';
import '../../features/todo/presentation/bloc/todo_bloc.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../security/biometric_authenticator.dart';
import '../security/device_integrity.dart';
import '../security/secure_token_storage.dart';
import '../security/security_policy.dart';

final sl = GetIt.instance;

/// One place to see every dependency the app has and how it's wired.
///
/// * The BLoC is a factory (a fresh instance per screen).
/// * Everything below it is a lazy singleton (one shared instance).
///
/// [useFakeBackend] swaps the remote data source between an in-memory fake
/// (demo mode, works offline) and the real Dio-based implementation. That
/// this is the *only* place the choice is made is the payoff of the
/// architecture: the domain and presentation layers never notice.
Future<void> initDependencies({
  required String apiBaseUrl,
  bool useFakeBackend = true,
  SecurityPolicy securityPolicy = const SecurityPolicy(),
}) async {
  await Hive.initFlutter();
  final todoBox = await Hive.openBox<Map>(TodoLocalDataSourceImpl.boxName);

  // Security
  sl.registerLazySingleton<SecurityPolicy>(() => securityPolicy);
  sl.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());
  sl.registerLazySingleton<BiometricAuthenticator>(
    () => LocalAuthBiometricAuthenticator(),
  );
  sl.registerLazySingleton<DeviceIntegrityChecker>(
    () => SafeDeviceIntegrityChecker(),
  );

  // Core
  sl.registerLazySingleton<Dio>(
    () => DioClient.create(
      baseUrl: apiBaseUrl,
      certificatePins: securityPolicy.certificatePins,
    ),
  );
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  if (useFakeBackend) {
    sl.registerLazySingleton<NetworkInfo>(
      () => const AlwaysOnlineNetworkInfo(),
    );
    sl.registerLazySingleton<TodoRemoteDataSource>(
      () => TodoFakeRemoteDataSource(),
    );
  } else {
    sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
    sl.registerLazySingleton<TodoRemoteDataSource>(
      () => TodoRemoteDataSourceImpl(sl()),
    );
  }

  // Todo feature
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(todoBox),
  );
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetAllTodos(sl()));
  sl.registerLazySingleton(() => CreateTodo(sl()));
  sl.registerLazySingleton(() => DeleteTodo(sl()));

  sl.registerFactory(
    () => TodoBloc(
      getAllTodos: sl(),
      createTodo: sl(),
      deleteTodo: sl(),
    ),
  );
}
