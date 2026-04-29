import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEManager {
  static BluetoothDevice? _device;

  static BluetoothCharacteristic? _cmdChar;
  static BluetoothCharacteristic? _statusChar;
  static BluetoothCharacteristic? _alertChar;

  static StreamSubscription? _statusSub;
  static StreamSubscription? _alertSub;

  static Function(Map<String, dynamic>)? _listener;

  static const SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const COMMAND_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static const STATUS_UUID  = "beb5483f-36e1-4688-b7f5-ea07361b26a8";
  static const ALERT_UUID   = "beb54840-36e1-4688-b7f5-ea07361b26a8";

  static bool get isConnected =>
      _device != null && _cmdChar != null;

  static Future<void> setConnection(
    BluetoothDevice d,
    BluetoothCharacteristic _,
  ) async {
    _device = d;

    try {
      await d.connect(timeout: const Duration(seconds: 10));
    } catch (_) {}

    final services = await d.discoverServices();

    for (var s in services) {
      if (s.uuid.toString().toLowerCase() == SERVICE_UUID) {
        for (var c in s.characteristics) {
          final u = c.uuid.toString().toLowerCase();

          if (u == COMMAND_UUID) _cmdChar = c;
          if (u == STATUS_UUID)  _statusChar = c;
          if (u == ALERT_UUID)   _alertChar = c;
        }
      }
    }

    await _startNotify();
  }

  static Future<void> _startNotify() async {
    // STATUS
    if (_statusChar != null) {
      try {
        await _statusChar!.setNotifyValue(true);
        await _statusSub?.cancel();

        _statusSub = _statusChar!.lastValueStream.listen((value) {
          _handleIncoming(value);
        });
      } catch (_) {}
    }

    // ALERT
    if (_alertChar != null) {
      try {
        await _alertChar!.setNotifyValue(true);
        await _alertSub?.cancel();

        _alertSub = _alertChar!.lastValueStream.listen((value) {
          _handleIncoming(value);
        });
      } catch (_) {}
    }
  }

  static void _handleIncoming(List<int> value) {
    if (value.isEmpty) return;

    try {
      final text = utf8.decode(value);

      try {
        final data = jsonDecode(text);
        if (data is Map<String, dynamic>) {
          _listener?.call(data);
        }
      } catch (_) {
        _listener?.call({
          "cmd": "RAW",
          "msg": text,
        });
      }
    } catch (_) {}
  }

  static void setListener(Function(Map<String, dynamic>) listener) {
    _listener = listener;
  }

  static Future<void> send(String cmd) async {
    if (_cmdChar == null) return;

    try {
      await _cmdChar!.write(
        utf8.encode(cmd),
        withoutResponse: true,
      );
    } catch (_) {}
  }

  static Future<void> disconnect() async {
    try {
      await _statusSub?.cancel();
      await _alertSub?.cancel();
      await _device?.disconnect();
    } catch (_) {}

    _device = null;
    _cmdChar = null;
    _statusChar = null;
    _alertChar = null;
    _listener = null;
  }
}
