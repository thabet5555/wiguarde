import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEManager {
  static BluetoothDevice? _device;
  static BluetoothCharacteristic? _tx; // RX من ESP (نستقبل منه)
  static BluetoothCharacteristic? _rx; // TX إلى ESP (نرسل له)

  static StreamSubscription? _sub;

  static Function(String)? onRaw;

  static const SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const RX_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"; // نكتب له
  static const TX_UUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"; // نقرأ منه

  static bool get isConnected => _device != null && _rx != null;

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

          if (u == RX_UUID) _rx = c; // نرسل
          if (u == TX_UUID) _tx = c; // نستقبل
        }
      }
    }

    if (_tx != null) {
      await _tx!.setNotifyValue(true);

      _sub?.cancel();
      _sub = _tx!.lastValueStream.listen((data) {
        final text = utf8.decode(data);
        print("ESP => $text");
        onRaw?.call(text);
      });
    }
  }

  static Future<void> send(String cmd) async {
    if (_rx == null) return;

    await _rx!.write(
      utf8.encode(cmd + "\n"), // 🔥 مهم
      withoutResponse: true,
    );
  }

  static void setListener(Function(String) fn) {
    onRaw = fn;
  }
}
