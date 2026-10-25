import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_clean_architecture_template/core/security/biometric_authenticator.dart';
import 'package:flutter_clean_architecture_template/core/security/device_integrity.dart';
import 'package:flutter_clean_architecture_template/core/security/security_gate.dart';
import 'package:flutter_clean_architecture_template/core/security/security_policy.dart';

class FakeIntegrityChecker implements DeviceIntegrityChecker {
  FakeIntegrityChecker({required this.compromised});

  final bool compromised;

  @override
  Future<bool> isCompromised() async => compromised;
}

class FakeBiometricAuthenticator implements BiometricAuthenticator {
  FakeBiometricAuthenticator({this.available = true, this.succeeds = true});

  final bool available;
  bool succeeds;
  int authenticateCalls = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate({required String reason}) async {
    authenticateCalls++;
    return succeeds;
  }
}

void main() {
  const appKey = Key('app');

  Future<void> pumpGate(
    WidgetTester tester, {
    required SecurityPolicy policy,
    DeviceIntegrityChecker? integrity,
    BiometricAuthenticator? biometric,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SecurityGate(
          policy: policy,
          integrityChecker: integrity ?? FakeIntegrityChecker(compromised: false),
          biometricAuthenticator: biometric ?? FakeBiometricAuthenticator(),
          child: const Scaffold(body: Text('app', key: appKey)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the app on a clean device with no biometric required',
      (tester) async {
    await pumpGate(tester, policy: const SecurityPolicy());

    expect(find.byKey(appKey), findsOneWidget);
  });

  testWidgets('blocks a compromised device when the policy says so',
      (tester) async {
    await pumpGate(
      tester,
      policy: const SecurityPolicy(blockCompromisedDevices: true),
      integrity: FakeIntegrityChecker(compromised: true),
    );

    expect(find.text('Device not supported'), findsOneWidget);
    expect(find.byKey(appKey), findsNothing);
  });

  testWidgets('lets a compromised device through when blocking is off',
      (tester) async {
    await pumpGate(
      tester,
      policy: const SecurityPolicy(),
      integrity: FakeIntegrityChecker(compromised: true),
    );

    expect(find.byKey(appKey), findsOneWidget);
  });

  testWidgets('unlocks the app after successful biometric authentication',
      (tester) async {
    final biometric = FakeBiometricAuthenticator();

    await pumpGate(
      tester,
      policy: const SecurityPolicy(requireBiometricUnlock: true),
      biometric: biometric,
    );

    expect(biometric.authenticateCalls, 1);
    expect(find.byKey(appKey), findsOneWidget);
  });

  testWidgets('stays locked when biometric authentication fails, and retries',
      (tester) async {
    final biometric = FakeBiometricAuthenticator(succeeds: false);

    await pumpGate(
      tester,
      policy: const SecurityPolicy(requireBiometricUnlock: true),
      biometric: biometric,
    );

    expect(find.text('App locked'), findsOneWidget);
    expect(find.byKey(appKey), findsNothing);

    biometric.succeeds = true;
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(biometric.authenticateCalls, 2);
    expect(find.byKey(appKey), findsOneWidget);
  });

  testWidgets('skips the lock when no biometrics are available',
      (tester) async {
    await pumpGate(
      tester,
      policy: const SecurityPolicy(requireBiometricUnlock: true),
      biometric: FakeBiometricAuthenticator(available: false),
    );

    expect(find.byKey(appKey), findsOneWidget);
  });
}
