import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEManager {
  static BluetoothDevice? _device;

  static BluetoothCharacteristic? _cmdChar;
  static BluetoothCharacteristic? _notifyChar;

  static StreamSubscription? _sub;

  static Function(Map<String, dynamic>)? _listener;

  static String _buffer = "";

  static bool get isConnected =>
      _device != null && _cmdChar != null;

  static Future<void> setConnection(
    BluetoothDevice d,
    BluetoothCharacteristic writeChar,
  ) async {
    _device = d;
    _cmdChar = writeChar;

    final services = await d.discoverServices();

    for (var s in services) {
      for (var c in s.characteristics) {
        if (c.properties.notify) {
          _notifyChar = c;
        }
      }
    }

    await _startNotify();
  }

  static Future<void> _startNotify() async {
    if (_notifyChar == null) return;

    await _notifyChar!.setNotifyValue(true);
    await Future.delayed(const Duration(milliseconds: 300));

    await _sub?.cancel();

    _sub = _notifyChar!.onValueReceived.listen((value) {
      if (value.isEmpty) return;

      final chunk = utf8.decode(value);
      print("BLE CHUNK: $chunk");

      _buffer += chunk;

      try {
        final data = jsonDecode(_buffer);

        if (data is Map<String, dynamic>) {
          print("JSON OK: $data");

          _listener?.call(data);
          _buffer = "";
        }
      } catch (_) {
        // ننتظر باقي البيانات
      }
    });
  }

  static void setListener(Function(Map<String, dynamic>) listener) {
    _listener = listener;
  }

  static Future<void> send(String cmd,
      [Map<String, dynamic>? data]) async {
    if (_cmdChar == null) return;

    final payload = jsonEncode({
      "cmd": cmd,
      "data": data ?? {}
    });

    await _cmdChar!.write(
      utf8.encode(payload),
      withoutResponse: true,
    );
  }

  static Future<void> disconnect() async {
    await _sub?.cancel();
    await _device?.disconnect();

    _device = null;
    _cmdChar = null;
    _notifyChar = null;
    _listener = null;
    _buffer = "";
  }
}
