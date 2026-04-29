import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEManager {
  static BluetoothDevice? _device;
  static BluetoothCharacteristic? _writeChar;
  static BluetoothCharacteristic? _notifyChar;

  static StreamSubscription? _notifySub;
  static Function(Map<String, dynamic>)? _listener;

  // ✅ حالة الاتصال
  static bool get isConnected =>
      _device != null && _writeChar != null;

  // 🔵 ربط الجهاز واختيار الخصائص الصح
  static Future<void> setConnection(
    BluetoothDevice d,
    BluetoothCharacteristic selectedChar,
  ) async {
    _device = d;

    try {
      await d.connect(timeout: const Duration(seconds: 10));
    } catch (_) {}

    final services = await d.discoverServices();

    for (var s in services) {
      for (var c in s.characteristics) {
        // 🔥 للكتابة
        if (_writeChar == null &&
            (c.properties.write || c.properties.writeWithoutResponse)) {
          _writeChar = c;
        }

        // 🔥 للاستقبال
        if (_notifyChar == null && c.properties.notify) {
          _notifyChar = c;
        }
      }
    }

    await _startNotify();
  }

  // 🔔 تشغيل الاستقبال
  static Future<void> _startNotify() async {
    if (_notifyChar == null) return;

    try {
      await _notifyChar!.setNotifyValue(true);

      await _notifySub?.cancel();

      _notifySub = _notifyChar!.lastValueStream.listen((value) {
        if (value.isEmpty) return;

        try {
          final text = utf8.decode(value);
          final data = jsonDecode(text);

          if (data is Map<String, dynamic>) {
            _listener?.call(data);
          }
        } catch (_) {}
      });
    } catch (_) {}
  }

  // 🎧 استقبال البيانات
  static void setListener(Function(Map<String, dynamic>) listener) {
    _listener = listener;
  }

  // 📤 إرسال أوامر
  static Future<void> send(
    String cmd, [
    Map<String, dynamic>? data,
  ]) async {
    if (_writeChar == null) return;

    final payload = {
      "cmd": cmd,
      if (data != null) ...data,
    };

    try {
      await _writeChar!.write(
        utf8.encode(jsonEncode(payload)),
        withoutResponse: true,
      );
    } catch (_) {}
  }

  // 🔌 فصل الاتصال
  static Future<void> disconnect() async {
    try {
      await _notifySub?.cancel();
      await _device?.disconnect();
    } catch (_) {}

    _device = null;
    _writeChar = null;
    _notifyChar = null;
    _listener = null;
  }
}
