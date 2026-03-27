import 'dart:async';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  ConnectivityService._internal() {
    _statusController.add(InternetStatus.connected);
    _subscription = InternetConnection().onStatusChange.listen((status) {
      if (status == InternetStatus.disconnected) {
        HapticFeedback.vibrate();
      }
      _statusController.add(status);
    });
  }

  static final ConnectivityService instance = ConnectivityService._internal();

  final _statusController = StreamController<InternetStatus>.broadcast();
  late final StreamSubscription<InternetStatus> _subscription;

  Stream<InternetStatus> get onStatusChange => _statusController.stream;

  void dispose() {
    _subscription.cancel();
    _statusController.close();
  }
}
