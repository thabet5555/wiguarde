import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEManager {
  static BluetoothDevice? _device;
  static BluetoothCharacteristic? _char;

  // 🔥 هجمة واحدة
  static List<Map<String, dynamic>> attacks = [];

  // 🔥 4 تقارير ثابتة
  static List<Map<String, dynamic>> reports = [
    {
      "title": "تم اكتشاف هجوم",
      "type": "DEAUTH ATTACK",
      "date": "2026-04-30",
      "time": "10:20",
    },
    {
      "title": "تحليل الشبكة",
      "type": "Network Scan",
      "date": "2026-04-30",
      "time": "10:21",
    },
    {
      "title": "تحذير أمني",
      "type": "Evil Twin",
      "date": "2026-04-30",
      "time": "10:22",
    },
    {
      "title": "تأكيد الحالة",
      "type": "Safe/Unsafe Check",
      "date": "2026-04-30",
      "time": "10:23",
    },
  ];

  static bool get isConnected =>
      _device != null && _char != null;

  static Future<void> setConnection(
    BluetoothDevice d,
    BluetoothCharacteristic c,
  ) async {
    _device = d;
    _char = c;
  }

  static void addAttack(Map<String, dynamic> attack) {
    if (attacks.isEmpty) {
      attacks.add(attack); // 🔥 هجمة واحدة فقط
    }
  }

  static Future<void> send(String cmd) async {
    if (_char == null) return;

    await _char!.write(
      utf8.encode(cmd),
      withoutResponse: true,
    );
  }
}
