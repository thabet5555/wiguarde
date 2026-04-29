import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEManager {
  static BluetoothDevice? _device;
  static BluetoothCharacteristic? _char;

  static StreamSubscription? _notifySub;
  static Function(Map<String, dynamic>)? _listener;

  static Future<void> setConnection(
    BluetoothDevice d,
    BluetoothCharacteristic c,
  ) async {
    _device = d;
    _char = c;

    try {
      await d.connect();
    } catch (_) {}

    await _startNotify();
  }

  static Future<void> _startNotify() async {
    if (_char == null) return;

    await _char!.setNotifyValue(true);

    _notifySub = _char!.lastValueStream.listen((value) {
      try {
        final data = jsonDecode(utf8.decode(value));
        if (data is Map<String, dynamic>) {
          _listener?.call(data);
        }
      } catch (_) {}
    });
  }

  static void setListener(Function(Map<String, dynamic>) listener) {
    _listener = listener;
  }
}
