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

  // ⚠️ UUID الخاص بك من ESP (UART)
  static const SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const COMMAND_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"; // RX
  static const STATUS_UUID  = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"; // TX
  static const ALERT_UUID   = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";

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
          if (u == STATUS_UUID) {
            _statusChar = c;
            _alertChar = c; // نفس TX
          }
        }
      }
    }

    await _startNotify();
  }

  static Future<void> _startNotify() async {
    if (_statusChar != null) {
      try {
        await _statusChar!.setNotifyValue(true);
        await _statusSub?.cancel();

        _statusSub = _statusChar!.lastValueStream.listen((value) {
          _handleIncoming(value);
        });
      } catch (_) {}
    }
  }

  static void _handleIncoming(List<int> value) {
    if (value.isEmpty) return;

    try {
      final text = utf8.decode(value);

      // 🔥 تحويل نتائج scan إلى قائمة
      if (text.contains("Networks found")) {
        final lines = text.split("\n");
        final list = <String>[];

        for (var l in lines) {
          if (l.contains(":")) {
            final parts = l.split(":");
            if (parts.length > 1) {
              final name = parts[1].split("(")[0].trim();
              if (name.isNotEmpty) list.add(name);
            }
          }
        }

        _listener?.call({
          "cmd": "WIFI_LIST",
          "list": list,
        });
        return;
      }

      // 🔥 أي نص = Alert / Status
      _listener?.call({
        "cmd": "RAW",
        "msg": text,
      });

    } catch (_) {}
  }

  static void setListener(Function(Map<String, dynamic>) listener) {
    _listener = listener;
  }

  // 🔥 إرسال أوامر ESP
  static Future<void> send(String cmd, [Map<String, dynamic>? data]) async {
    if (_cmdChar == null) return;

    try {
      String message = cmd;

      if (data != null) {
        message += " " + jsonEncode(data);
      }

      await _cmdChar!.write(
        utf8.encode(message),
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
