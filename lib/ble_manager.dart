import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEManager {
  static BluetoothDevice? _device;
  static BluetoothCharacteristic? _characteristic;

  static List<Map<String, dynamic>> attacks = [];
  static List<Map<String, dynamic>> reports = [];
  static List<String> networks = [];

  static bool scanning = false;
  static String currentNetwork = "";

  static bool get isConnected =>
      _device != null && _characteristic != null;

  static BluetoothDevice? get device => _device;

  static Future<void> setConnection(
    BluetoothDevice device,
    BluetoothCharacteristic characteristic,
  ) async {
    _device = device;
    _characteristic = characteristic;

    try {
      await characteristic.setNotifyValue(true);

      characteristic.lastValueStream.listen((value) {
        try {
          final text = utf8.decode(value);

          final data =
              jsonDecode(text) as Map<String, dynamic>;

          _handleIncoming(data);
        } catch (_) {}
      });
    } catch (_) {}
  }

  static void _handleIncoming(
    Map<String, dynamic> data,
  ) {
    final cmd =
        data["cmd"]?.toString() ?? "";

    if (cmd == "NETWORK") {
      final ssid =
          data["ssid"]?.toString() ?? "";

      if (ssid.isNotEmpty &&
          !networks.contains(ssid)) {
        networks.add(ssid);
      }

      currentNetwork = ssid;
    }

    if (cmd == "ATTACK") {
      final attack = {
        "type": data["type"] ?? "UNKNOWN",
        "ssid": data["ssid"] ?? "",
        "risk": data["risk"] ?? 0,
        "date": data["date"] ?? "",
        "time": data["time"] ?? "",
      };

      attacks.insert(0, attack);

      reports.insert(0, {
        "title": "تم اكتشاف هجوم",
        "type": attack["type"],
        "ssid": attack["ssid"],
        "date": attack["date"],
        "time": attack["time"],
      });
    }

    if (cmd == "REPORT") {
      reports.insert(0, {
        "title": data["title"] ?? "تقرير",
        "type": data["type"] ?? "",
        "ssid": data["ssid"] ?? "",
        "date": data["date"] ?? "",
        "time": data["time"] ?? "",
      });
    }
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

  static Future<void> send(
    String command,
  ) async {
    if (_characteristic == null) return;

    await _characteristic!.write(
      utf8.encode(command),
      withoutResponse: true,
    );
  }

  static Future<void> startScan() async {
    scanning = true;

    await send(
      jsonEncode({
        "cmd": "START_SCAN",
      }),
    );
  }

  static Future<void> stopScan() async {
    scanning = false;

    await send(
      jsonEncode({
        "cmd": "STOP_SCAN",
      }),
    );
  }

  static void clearData() {
    attacks.clear();
    reports.clear();
    networks.clear();
    currentNetwork = "";
  }
}
