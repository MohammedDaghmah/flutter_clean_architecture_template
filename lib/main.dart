import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart' as di;
import 'core/security/biometric_authenticator.dart';
import 'core/security/device_integrity.dart';
import 'core/security/security_gate.dart';
import 'core/security/security_policy.dart';
import 'features/todo/presentation/bloc/todo_bloc.dart';
import 'features/todo/presentation/pages/todo_list_page.dart';

/// Demo mode: runs against an in-memory fake backend, no server needed.
/// Set to `false` and point [_apiBaseUrl] at a real REST API to use the
/// Dio-based remote data source instead.
const bool _useFakeBackend = true;
const String _apiBaseUrl = 'https://api.example.com';

/// Security settings for the whole app, in one place.
///
/// * Rooted / jailbroken devices are blocked in release builds only, because
///   emulators often look rooted and would block local development.
/// * Biometric unlock is off so the demo opens without enrolled fingerprints.
///   Set it to `true` to see the lock screen.
/// * Add your server's certificate fingerprints to enable pinning (see
///   `lib/core/security/certificate_fingerprint.dart`).
const SecurityPolicy _securityPolicy = SecurityPolicy(
  blockCompromisedDevices: kReleaseMode,
  requireBiometricUnlock: false,
  certificatePins: <String>{},
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies(
    apiBaseUrl: _apiBaseUrl,
    useFakeBackend: _useFakeBackend,
    securityPolicy: _securityPolicy,
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
      home: SecurityGate(
        policy: di.sl<SecurityPolicy>(),
        integrityChecker: di.sl<DeviceIntegrityChecker>(),
        biometricAuthenticator: di.sl<BiometricAuthenticator>(),
        child: BlocProvider(
          create: (_) => di.sl<TodoBloc>()..add(const LoadTodos()),
          child: const TodoListPage(),
        ),
      ),
    );
  }
}
