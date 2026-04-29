import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../ble_manager.dart';

class BluetoothScreen extends StatefulWidget {
  final Function() onConnected;

  const BluetoothScreen({super.key, required this.onConnected});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<ScanResult> devices = [];

  @override
  void initState() {
    super.initState();
    startScan();
  }

  Future<void> startScan() async {
    devices.clear();

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        devices = results
            .where((r) => r.device.platformName.contains("ESP32"))
            .toList();
      });
    });
  }

  Future<void> connect(BluetoothDevice d) async {
    await BLEManager.setConnection(d);
    widget.onConnected();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: startScan,
          )
        ],
      ),
      body: devices.isEmpty
          ? const Center(child: Text("شغل البلوتوث"))
          : ListView(
              children: devices.map((r) {
                final d = r.device;

                return ListTile(
                  title: Text(d.platformName),
                  subtitle: Text(d.remoteId.str),
                  trailing: ElevatedButton(
                    onPressed: () => connect(d),
                    child: const Text("Connect"),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
