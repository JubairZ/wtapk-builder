import 'package:connectivity_plus/connectivity_plus.dart';

/// Singleton connectivity service. Listen to [onStatusChanged] for updates.
/// Compatible with connectivity_plus 5.x (returns List<ConnectivityResult>)
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  final _connectivity = Connectivity();

  Stream<bool> get onStatusChanged => _connectivity.onConnectivityChanged
      .map((result) {
        if (result is List) {
          return !(result as List).every((r) => r == ConnectivityResult.none);
        }
        return result != ConnectivityResult.none;
      });

  Future<void> init() async {
    final result = await _connectivity.checkConnectivity();
    if (result is List) {
      _isOnline = !(result as List).every((r) => r == ConnectivityResult.none);
    } else {
      _isOnline = result != ConnectivityResult.none;
    }
    _connectivity.onConnectivityChanged.listen((r) {
      if (r is List) {
        _isOnline = !(r as List).every((e) => e == ConnectivityResult.none);
      } else {
        _isOnline = r != ConnectivityResult.none;
      }
    });
  }

  Future<bool> check() async {
    final result = await _connectivity.checkConnectivity();
    if (result is List) {
      _isOnline = !(result as List).every((r) => r == ConnectivityResult.none);
    } else {
      _isOnline = result != ConnectivityResult.none;
    }
    return _isOnline;
  }
}
