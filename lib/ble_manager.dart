import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEManager {
  static BluetoothDevice? _device;

  // 🔥 خصائص محددة بالـ UUID (مطابقة لكود ESP)
  static BluetoothCharacteristic? _cmdChar;     // WRITE
  static BluetoothCharacteristic? _statusChar;  // NOTIFY
  static BluetoothCharacteristic? _alertChar;   // NOTIFY

  static StreamSubscription? _statusSub;
  static StreamSubscription? _alertSub;

  static Function(Map<String, dynamic>)? _listener;

  // UUIDs (نفس اللي في ESP)
  static const SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const COMMAND_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static const STATUS_UUID  = "beb5483f-36e1-4688-b7f5-ea07361b26a8";
  static const ALERT_UUID   = "beb54840-36e1-4688-b7f5-ea07361b26a8";

  // حالة الاتصال
  static bool get isConnected =>
      _device != null && _cmdChar != null;

  // 🔵 ربط الجهاز + اكتشاف الخصائص الصحيحة بالـ UUID
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
      if (s.uuid.toString() == SERVICE_UUID) {
        for (var c in s.characteristics) {
          final u = c.uuid.toString();

          if (u == COMMAND_UUID) _cmdChar = c;
          if (u == STATUS_UUID)  _statusChar = c;
          if (u == ALERT_UUID)   _alertChar = c;
        }
      }
    }

    await _startNotify();
  }

  // 🔔 تفعيل الاستقبال من STATUS + ALERT
  static Future<void> _startNotify() async {
    // STATUS
    if (_statusChar != null) {
      await _statusChar!.setNotifyValue(true);
      await _statusSub?.cancel();

      _statusSub = _statusChar!.lastValueStream.listen((value) {
        _handleIncoming(value);
      });
    }

    // ALERT
    if (_alertChar != null) {
      await _alertChar!.setNotifyValue(true);
      await _alertSub?.cancel();

      _alertSub = _alertChar!.lastValueStream.listen((value) {
        _handleIncoming(value);
      });
    }
  }

  // 🔄 معالجة البيانات (JSON أو نص)
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
        // لو نص عادي
        _listener?.call({
          "cmd": "RAW",
          "msg": text,
        });
      }
    } catch (_) {}
  }

  // 🎧 تسجيل المستمع
  static void setListener(Function(Map<String, dynamic>) listener) {
    _listener = listener;
  }

  // 📤 إرسال أوامر (نص مباشر مثل الترمنال)
  static Future<void> send(String cmd) async {
    if (_cmdChar == null) return;

    try {
      await _cmdChar!.write(
        utf8.encode(cmd),
        withoutResponse: true,
      );
    } catch (_) {}
  }

  // 🔌 فصل
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
