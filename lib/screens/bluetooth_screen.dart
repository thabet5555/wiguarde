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
  bool scanning = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await Permission.locationWhenInUse.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();

    await Future.delayed(const Duration(seconds: 1));
    startScan();
  }

  Future<void> startScan() async {
    setState(() => scanning = true);

    await FlutterBluePlus.stopScan();

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
    );

    FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;

      setState(() {
        // 🔥 فلترة الأجهزة اللي فيها اسم (ESP فقط)
        devices = results
            .where((r) => r.device.platformName.isNotEmpty)
            .toList();
      });
    });

    await Future.delayed(const Duration(seconds: 10));
    if (mounted) setState(() => scanning = false);
  }

  Future<void> connect(BluetoothDevice d) async {
    try {
      await BLEManager.connect(d); // 🔥 الاتصال الصحيح

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ تم الاتصال بـ ${d.platformName}")),
      );

      widget.onConnected(d, d.characteristics.isNotEmpty
          ? d.characteristics.first
          : BluetoothCharacteristic(
              remoteId: d.remoteId,
              serviceUuid: Guid("0000"),
              characteristicUuid: Guid("0000"),
              descriptors: [],
              properties: CharacteristicProperties(),
            ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ فشل الاتصال: $e")),
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
      body: scanning
          ? const Center(child: CircularProgressIndicator())
          : devices.isEmpty
              ? const Center(child: Text("شغل البلوتوث والموقع"))
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
