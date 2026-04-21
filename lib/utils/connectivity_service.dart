import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final _connectivity = Connectivity();

  /// Quick check: is the device connected to a network?
  static Future<bool> isConnectedToNetwork() async {
    final result = await _connectivity.checkConnectivity();
    return result.first != ConnectivityResult.none;
  }

  /// Real check: can we actually reach the internet?
  /// Handles captive portals (hotel WiFi, conference WiFi, etc.)
  static Future<bool> isOnline() async {
    final connected = await isConnectedToNetwork();
    if (!connected) return false;

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Stream: emits true/false every time connectivity changes
  static Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged
      .map((result) => result.first != ConnectivityResult.none);
}
