import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEManager {
  static BluetoothDevice? _device;
  static BluetoothCharacteristic? _tx;
  static StreamSubscription? _notifySub;

  static Function(String)? _listener;

  static const SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const RX_UUID      = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  static const TX_UUID      = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";

  static bool get isConnected => _device != null && _tx != null;

  static Future<void> setConnection(BluetoothDevice d) async {
    _device = d;

    await d.connect(timeout: const Duration(seconds: 10));

    final services = await d.discoverServices();

    for (var s in services) {
      if (s.uuid.toString().toLowerCase() == SERVICE_UUID) {
        for (var c in s.characteristics) {
          final u = c.uuid.toString().toLowerCase();

          if (u == TX_UUID) _tx = c;

          if (u == RX_UUID) {
            await c.setNotifyValue(true);

            _notifySub?.cancel();
            _notifySub = c.lastValueStream.listen((value) {
              final msg = utf8.decode(value);
              _listener?.call(msg);
            });
          }
        }
      }
    }
  }

  static void setListener(Function(String) listener) {
    _listener = listener;
  }

  static Future<void> send(String cmd) async {
    if (_tx == null) return;
    await _tx!.write(utf8.encode(cmd), withoutResponse: true);
  }

  static Future<void> disconnect() async {
    await _notifySub?.cancel();
    await _device?.disconnect();

    _device = null;
    _tx = null;
  }
}
