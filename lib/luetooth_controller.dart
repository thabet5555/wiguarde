import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothController {
  static BluetoothDevice? device;
  static BluetoothCharacteristic? writeChar;

  static bool get isConnected => writeChar != null;

  static Future<void> send(String cmd) async {
    if (writeChar == null) return;
    await writeChar!.write(cmd.codeUnits);
  }
}