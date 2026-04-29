import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../ble_manager.dart';

class BluetoothScreen extends StatefulWidget {
  final Function(BluetoothDevice, BluetoothCharacteristic) onConnected;

  const BluetoothScreen({super.key, required this.onConnected});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<ScanResult> devices = [];

  @override
  void initState() {
    super.initState();
    initBluetooth();
  }

  Future<void> initBluetooth() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    try {
      await FlutterBluePlus.turnOn();
    } catch (_) {}

    startScan();
  }

  Future<void> startScan() async {
    await FlutterBluePlus.stopScan();
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() => devices = results);
    });
  }

  Future<void> connect(BluetoothDevice d) async {
    try {
      await d.connect();
      final services = await d.discoverServices();

      for (var s in services) {
        for (var c in s.characteristics) {
          if (c.properties.write) {
            await BLEManager.setConnection(d, c);
            widget.onConnected(d, c);
            return;
          }
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bluetooth")),
      body: devices.isEmpty
          ? const Center(child: Text("No devices found"))
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (_, i) {
                final d = devices[i].device;
                return ListTile(
                  title: Text(
                    d.platformName.isEmpty
                        ? "Unknown Device"
                        : d.platformName,
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => connect(d),
                    child: const Text("Connect"),
                  ),
                );
              },
            ),
    );
  }
}
