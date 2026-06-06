import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEManager {
  static BluetoothDevice? _device;
  static BluetoothCharacteristic? _characteristic;

  static List<Map<String, dynamic>> attacks = [];

  static List<Map<String, dynamic>> reports = [];

  static bool get isConnected =>
      _device != null && _characteristic != null;

  static BluetoothDevice? get device => _device;

  static Future<void> setConnection(
    BluetoothDevice device,
    BluetoothCharacteristic characteristic,
  ) async {
    _device = device;
    _characteristic = characteristic;
  }

  static void addAttack(
    Map<String, dynamic> attack,
  ) {
    attacks.insert(0, attack);

    reports.insert(0, {
      "title": "تم اكتشاف هجوم",
      "type": attack["type"] ?? "UNKNOWN",
      "ssid": attack["ssid"] ?? "",
      "date": attack["date"] ?? "",
      "time": attack["time"] ?? "",
    });
  }

  static Future<void> send(String command) async {
    if (_characteristic == null) return;

    await _characteristic!.write(
      utf8.encode(command),
      withoutResponse: true,
    );
  }

  static void clearData() {
    attacks.clear();
    reports.clear();
  }
}
