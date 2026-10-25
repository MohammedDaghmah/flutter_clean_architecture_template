import 'package:flutter/material.dart';

import 'biometric_authenticator.dart';
import 'device_integrity.dart';
import 'security_policy.dart';

enum _GateStatus { checking, blocked, locked, unlocked }

/// Wraps the app and decides whether [child] may be shown.
///
/// 1. If the policy blocks compromised devices and the device is rooted or
///    jailbroken, the app is replaced by a "not supported" screen.
/// 2. If the policy requires biometric unlock and biometrics are available,
///    the app stays locked until the user authenticates.
/// 3. Otherwise [child] is shown.
///
/// The gate depends only on the [DeviceIntegrityChecker] and
/// [BiometricAuthenticator] contracts and on a [SecurityPolicy] value, so it
/// is tested with fakes and needs no platform plugin.
class SecurityGate extends StatefulWidget {
  const SecurityGate({
    required this.policy,
    required this.integrityChecker,
    required this.biometricAuthenticator,
    required this.child,
    super.key,
  });

  final SecurityPolicy policy;
  final DeviceIntegrityChecker integrityChecker;
  final BiometricAuthenticator biometricAuthenticator;
  final Widget child;

  @override
  State<SecurityGate> createState() => _SecurityGateState();
}

class _SecurityGateState extends State<SecurityGate> {
  _GateStatus _status = _GateStatus.checking;

  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  Future<void> _evaluate() async {
    final policy = widget.policy;

    if (policy.blockCompromisedDevices &&
        await widget.integrityChecker.isCompromised()) {
      _setStatus(_GateStatus.blocked);
      return;
    }

    if (policy.requireBiometricUnlock &&
        await widget.biometricAuthenticator.isAvailable()) {
      _setStatus(_GateStatus.locked);
      await _unlock();
      return;
    }

    _setStatus(_GateStatus.unlocked);
  }

  Future<void> _unlock() async {
    final success = await widget.biometricAuthenticator.authenticate(
      reason: 'Authenticate to open the app',
    );
    if (success) _setStatus(_GateStatus.unlocked);
  }

  void _setStatus(_GateStatus status) {
    if (!mounted) return;
    setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case _GateStatus.checking:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case _GateStatus.blocked:
        return const _GateMessage(
          icon: Icons.gpp_bad_outlined,
          title: 'Device not supported',
          message: 'This app cannot run on a rooted or jailbroken device.',
        );
      case _GateStatus.locked:
        return _GateMessage(
          icon: Icons.lock_outline,
          title: 'App locked',
          message: 'Authenticate to continue.',
          actionLabel: 'Unlock',
          onAction: _unlock,
        );
      case _GateStatus.unlocked:
        return widget.child;
    }
  }
}

/// One full-screen message layout, reused by the blocked and locked states.
class _GateMessage extends StatelessWidget {
  const _GateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64),
              const SizedBox(height: 16),
              Text(title, style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              if (actionLabel != null) ...[
                const SizedBox(height: 24),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
