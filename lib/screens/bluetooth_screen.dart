import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../ble_manager.dart';

const String SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
const String RX_UUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"; // write
const String TX_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"; // notify

class BluetoothScreen extends StatefulWidget {
  final Function(BluetoothDevice, BluetoothCharacteristic, BluetoothCharacteristic) onConnected;
  const BluetoothScreen({super.key, required this.onConnected});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<ScanResult> devices = [];
  bool isScanning = false;
  bool isConnecting = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await [
      Permission.locationWhenInUse,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
    startScan();
  }

  Future<void> startScan() async {
    setState(() {
      isScanning = true;
      devices.clear();
    });
    await FlutterBluePlus.stopScan();
    FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;
      final filtered = results.where((r) => r.device.platformName.contains("ESP32_AttackDetector")).toList();
      setState(() => devices = filtered);
    });
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
    setState(() => isScanning = false);
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    setState(() => isScanning = false);
  }

  Future<void> connect(BluetoothDevice device) async {
    if (isConnecting) return;
    setState(() => isConnecting = true);
    try {
      await device.connect(timeout: const Duration(seconds: 15));
      final services = await device.discoverServices();
      BluetoothCharacteristic? txChar, rxChar;
      for (final service in services) {
        if (service.uuid.toString().toUpperCase() == SERVICE_UUID) {
          for (final c in service.characteristics) {
            final uuid = c.uuid.toString().toUpperCase();
            if (uuid == TX_UUID) txChar = c;
            else if (uuid == RX_UUID) rxChar = c;
          }
          break;
        }
      }
      if (txChar == null || rxChar == null) {
        throw Exception("لم يتم العثور على الخاصيات المطلوبة");
      }
      await txChar!.setNotifyValue(true);
      widget.onConnected(device, txChar, rxChar);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ فشل الاتصال: $e")),
      );
    } finally {
      if (mounted) setState(() => isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text("Bluetooth"),
        actions: [
          IconButton(
            onPressed: isScanning ? stopScan : startScan,
            icon: Icon(isScanning ? Icons.stop : Icons.refresh),
          ),
        ],
      ),
      body: isScanning && devices.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (_, i) {
                final device = devices[i].device;
                return Card(
                  color: const Color(0xFF1E1E2E),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.bluetooth, color: Colors.blue),
                    title: Text(
                      device.platformName.isEmpty ? "ESP32 Device" : device.platformName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      device.remoteId.str,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: ElevatedButton(
                      onPressed: isConnecting ? null : () => connect(device),
                      child: isConnecting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text("Connect"),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
