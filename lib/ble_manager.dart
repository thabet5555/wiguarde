import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEManager {
  static BluetoothDevice? _device;
  static BluetoothCharacteristic? _rx;
  static BluetoothCharacteristic? _tx;
  static StreamSubscription? _sub;

  static Function(String)? _onLine;
  static String _buffer = "";

  static const SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const RX_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  static const TX_UUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";

  static bool get isConnected => _rx != null && _tx != null;

  static Future<void> connect(BluetoothDevice d) async {
    _device = d;

    try {
      await d.connect(timeout: const Duration(seconds: 10));
    } catch (_) {}

    final services = await d.discoverServices();

    for (var s in services) {
      if (s.uuid.toString().toLowerCase() == SERVICE_UUID) {
        for (var c in s.characteristics) {
          final u = c.uuid.toString().toLowerCase();
          if (u == RX_UUID) _rx = c;
          if (u == TX_UUID) _tx = c;
        }
      }
    }

    if (_tx != null) {
      await _tx!.setNotifyValue(true);

      _sub?.cancel();
      _sub = _tx!.lastValueStream.listen((data) {
        final chunk = utf8.decode(data);
        _buffer += chunk;

        while (_buffer.contains('\n')) {
          final i = _buffer.indexOf('\n');
          final line = _buffer.substring(0, i).trim();
          _buffer = _buffer.substring(i + 1);

          if (line.isNotEmpty) {
            _onLine?.call(line);
          }
        }
      });
    }
  }

  static Future<void> send(String cmd) async {
    if (_rx == null) return;

    await _rx!.write(
      utf8.encode(cmd + "\n"),
      withoutResponse: true,
    );
  }

  static void setListener(Function(String) fn) {
    _onLine = fn;
  }
}
