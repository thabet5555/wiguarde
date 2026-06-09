import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEManager {
  static BluetoothDevice? _device;
  static BluetoothCharacteristic? _txCharacteristic; // استقبال من ESP (notify)
  static BluetoothCharacteristic? _rxCharacteristic; // إرسال إلى ESP (write)

  static List<Map<String, dynamic>> attacks = [];
  static List<Map<String, dynamic>> reports = [];
  static List<String> networks = [];
  static List<int> networksRSSI = [];

  static bool isMonitoring = false;
  static String currentNetwork = "";

  static bool get isConnected => _device != null && _txCharacteristic != null;

  static void clearData() {
    attacks.clear();
    reports.clear();
    networks.clear();
    networksRSSI.clear();
    currentNetwork = "";
    isMonitoring = false;
  }

  static Future<void> setConnection(
    BluetoothDevice device,
    BluetoothCharacteristic txChar,
    BluetoothCharacteristic rxChar,
  ) async {
    _device = device;
    _txCharacteristic = txChar;
    _rxCharacteristic = rxChar;

    try {
      await _txCharacteristic!.setNotifyValue(true);
      _txCharacteristic!.lastValueStream.listen((value) {
        try {
          String text = utf8.decode(value);
          _handleIncoming(text);
        } catch (e) {
          print("Decode error: $e");
        }
      });
    } catch (e) {
      print("Set connection error: $e");
      rethrow;
    }
  }

  static void _handleIncoming(String text) {
    print("📥 ESP: $text");

    if (text.startsWith("Networks found:")) {
      _parseNetworks(text);
      return;
    }

    if (text.startsWith("OK:") || text.startsWith("ERR:")) {
      _addReport("System", text, "");
      if (text.contains("Monitoring started")) isMonitoring = true;
      if (text.contains("Monitoring stopped")) isMonitoring = false;
      if (text.contains("Selected")) {
        // استخراج اسم الشبكة من "OK: Selected MyWiFi (Ch 6)"
        RegExp reg = RegExp(r'Selected (.+?) \(');
        Match? m = reg.firstMatch(text);
        if (m != null) currentNetwork = m.group(1)!;
      }
      return;
    }

    if (text.contains("FLOOD") ||
        text.contains("SPOOFING") ||
        text.contains("SCAN") ||
        text.contains("TWIN") ||
        text.contains("FRAG")) {
      _detectAttack(text);
      return;
    }

    _addReport("Info", text, "");
  }

  static void _parseNetworks(String text) {
    networks.clear();
    networksRSSI.clear();
    List<String> lines = text.split('\n');
    for (String line in lines) {
      RegExp regExp = RegExp(r'^\d+:\s+(.+)\s+\((-?\d+)dBm\)');
      Match? match = regExp.firstMatch(line);
      if (match != null) {
        networks.add(match.group(1)!);
        networksRSSI.add(int.parse(match.group(2)!));
      }
    }
  }

  static void _detectAttack(String text) {
    String type = "";
    if (text.contains("DEAUTH")) type = "Deauth Flood";
    else if (text.contains("BEACON")) type = "Beacon Flood";
    else if (text.contains("PROBE")) type = "Probe Flood";
    else if (text.contains("MAC")) type = "MAC Spoofing";
    else if (text.contains("ARP")) type = "ARP Spoofing";
    else if (text.contains("FRAG")) type = "Fragmentation";
    else if (text.contains("RTS")) type = "RTS Flood";
    else if (text.contains("SCAN")) type = "Network Scan";
    else if (text.contains("TWIN")) type = "Evil Twin";
    else type = text;

    int risk = 1;
    if (type.contains("Deauth") || type.contains("Evil")) risk = 3;
    else if (type.contains("Spoofing") || type.contains("Flood")) risk = 2;

    Map<String, dynamic> attack = {
      "type": type,
      "ssid": currentNetwork,
      "risk": risk,
      "date": DateTime.now().toIso8601String(),
      "time": "${DateTime.now().hour}:${DateTime.now().minute}",
    };
    attacks.insert(0, attack);
    _addReport("Attack", type, currentNetwork);
  }

  static void _addReport(String title, String msg, String ssid) {
    reports.insert(0, {
      "title": title,
      "type": msg,
      "ssid": ssid,
      "date": DateTime.now().toIso8601String(),
      "time": "${DateTime.now().hour}:${DateTime.now().minute}",
    });
  }

  static Future<void> send(String command) async {
    if (_rxCharacteristic == null) {
      print("❌ RX characteristic is null");
      return;
    }
    try {
      await _rxCharacteristic!.write(utf8.encode(command), withoutResponse: false);
      print("📤 Sent: $command");
    } catch (e) {
      print("Send error: $e");
    }
  }

  // أوامر ESP
  static Future<void> scanNetworks() async => send("scan");
  static Future<void> selectNetwork(int index) async {
    if (index >= 0 && index < networks.length) {
      await send("select ${index + 1}");
    }
  }
  static Future<void> startMonitoring() async => send("monitor");
  static Future<void> stopMonitoring() async => send("stop");
  static Future<void> backToMenu() async => send("back");
  static Future<void> getHistory() async => send("history");
  static Future<void> getStatus() async => send("status");
  static Future<void> setThreshold(String name, int value) async =>
      send("threshold $name $value");
}
