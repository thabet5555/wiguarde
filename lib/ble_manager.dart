import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEManager {
  static BluetoothDevice? _device;
  static BluetoothCharacteristic? _char;

  static StreamSubscription? _notifySub;
  static Function(Map<String, dynamic>)? _listener;

  // ✅ حالة الاتصال
  static bool get isConnected =>
      _device != null && _char != null;

  // 🔵 ربط الجهاز
  static Future<void> setConnection(
    BluetoothDevice d,
    BluetoothCharacteristic c,
  ) async {
    _device = d;
    _char = c;

    try {
      await d.connect(timeout: const Duration(seconds: 10));
    } catch (_) {}

    await _startNotify();
  }

  // 🔔 استقبال البيانات
  static Future<void> _startNotify() async {
    if (_char == null) return;

    try {
      await _char!.setNotifyValue(true);

      await _notifySub?.cancel();

      _notifySub = _char!.lastValueStream.listen((value) {
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

  // 🎧 مستمع
  static void setListener(Function(Map<String, dynamic>) listener) {
    _listener = listener;
  }

  // 📤 إرسال أوامر (🔥 هذا سبب الخطأ)
  static Future<void> send(
    String cmd, [
    Map<String, dynamic>? data,
  ]) async {
    if (_char == null) return;

    final payload = {
      "cmd": cmd,
      if (data != null) ...data,
    };

    try {
      await _char!.write(
        utf8.encode(jsonEncode(payload)),
        withoutResponse: true,
      );
    } catch (_) {}
  }

  // 🔌 فصل
  static Future<void> disconnect() async {
    try {
      await _notifySub?.cancel();
      await _device?.disconnect();
    } catch (_) {}

    _device = null;
    _char = null;
    _listener = null;
  }
}
