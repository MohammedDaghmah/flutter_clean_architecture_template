import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction over connectivity checks so repositories can decide whether
/// to hit the remote data source or fall back to cache — and so this check
/// can be mocked out entirely in tests.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}

/// Used in demo mode (fake in-memory backend) so the template works
/// offline and out of the box.
class AlwaysOnlineNetworkInfo implements NetworkInfo {
  const AlwaysOnlineNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}
