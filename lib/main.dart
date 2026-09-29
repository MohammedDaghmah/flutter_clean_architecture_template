import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart' as di;
import 'features/todo/presentation/bloc/todo_bloc.dart';
import 'features/todo/presentation/pages/todo_list_page.dart';

/// Demo mode: runs against an in-memory fake backend, no server needed.
/// Set to `false` and point [_apiBaseUrl] at a real REST API to use the
/// Dio-based remote data source instead.
const bool _useFakeBackend = true;
const String _apiBaseUrl = 'https://api.example.com';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies(
    apiBaseUrl: _apiBaseUrl,
    useFakeBackend: _useFakeBackend,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Architecture Template',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: BlocProvider(
        create: (_) => di.sl<TodoBloc>()..add(const LoadTodos()),
        child: const TodoListPage(),
      ),
    );
  }
}
