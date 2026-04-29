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
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await Permission.locationWhenInUse.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();

    startScan();
  }

  Future<void> startScan() async {
    setState(() => isScanning = true);

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
    );

    FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;
      setState(() => devices = results);
    });

    await Future.delayed(const Duration(seconds: 10));
    if (mounted) setState(() => isScanning = false);
  }

  Future<void> connect(BluetoothDevice d) async {
    try {
      await d.connect();

      final services = await d.discoverServices();

      BluetoothCharacteristic? writeChar;

      for (var s in services) {
        for (var c in s.characteristics) {
          if (c.properties.write || c.properties.writeWithoutResponse) {
            writeChar = c;
          }
        }
      }

      if (writeChar != null) {
        await BLEManager.setConnection(d, writeChar);
        widget.onConnected(d, writeChar);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ لا يوجد characteristic للإرسال")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")),
      );
    }
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
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
      body: isScanning
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (_, i) {
                final d = devices[i].device;

                return ListTile(
                  title: Text(
                    d.platformName.isEmpty
                        ? "Unknown"
                        : d.platformName,
                  ),
                  subtitle: Text(d.remoteId.str),
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
