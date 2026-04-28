import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
    FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((r) {
      setState(() => devices = r);
    });
  }

  Future<void> connect(BluetoothDevice d) async {
    await d.connect();

    final services = await d.discoverServices();

    for (var s in services) {
      for (var c in s.characteristics) {
        if (c.properties.write) {
          BLEManager.setConnection(d, c);
          widget.onConnected(d, c);
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bluetooth")),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (_, i) {
          final d = devices[i].device;

          return ListTile(
            title: Text(d.platformName.isEmpty ? "Unknown" : d.platformName),
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