import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../ble_manager.dart';

class BluetoothScreen extends StatefulWidget {
  final Function(
    BluetoothDevice,
    BluetoothCharacteristic,
  ) onConnected;

  const BluetoothScreen({
    super.key,
    required this.onConnected,
  });

  @override
  State<BluetoothScreen> createState() =>
      _BluetoothScreenState();
}

class _BluetoothScreenState
    extends State<BluetoothScreen> {

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
    setState(() {
      isScanning = true;
      devices.clear();
    });

    await FlutterBluePlus.stopScan();

    FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;

      final filtered = results.where((r) {
        final name = r.device.platformName;

        return name.isNotEmpty;
      }).toList();

      setState(() {
        devices = filtered;
      });
    });

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
    );

    await Future.delayed(
      const Duration(seconds: 10),
    );

    if (mounted) {
      setState(() {
        isScanning = false;
      });
    }
  }

  Future<void> connect(
    BluetoothDevice device,
  ) async {
    try {
      await device.connect(
        timeout: const Duration(seconds: 15),
      );

      final services =
          await device.discoverServices();

      BluetoothCharacteristic? target;

      for (final service in services) {
        for (final c
            in service.characteristics) {

          if ((c.properties.write ||
                  c.properties.writeWithoutResponse) &&
              c.properties.notify) {
            target = c;
            break;
          }
        }
      }

      if (target == null) {
        for (final service in services) {
          for (final c
              in service.characteristics) {
            if (c.properties.write ||
                c.properties.writeWithoutResponse) {
              target = c;
              break;
            }
          }
        }
      }

      if (target == null) {
        throw Exception(
          "Characteristic غير موجود",
        );
      }

      await BLEManager.setConnection(
        device,
        target,
      );

      widget.onConnected(
        device,
        target,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "✅ تم الاتصال بـ ${device.platformName}",
          ),
        ),
      );
    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "❌ فشل الاتصال\n$e",
          ),
        ),
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
      backgroundColor:
          const Color(0xFF0F0F1A),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF1E1E2E),
        title: const Text(
          "Bluetooth",
        ),
        actions: [
          IconButton(
            onPressed: startScan,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: isScanning
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (_, i) {

                final device =
                    devices[i].device;

                return Card(
                  color:
                      const Color(
                    0xFF1E1E2E,
                  ),
                  child: ListTile(
                    leading:
                        const Icon(
                      Icons.bluetooth,
                      color: Colors.blue,
                    ),
                    title: Text(
                      device.platformName
                              .isEmpty
                          ? "Unknown Device"
                          : device.platformName,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      device.remoteId.str,
                      style:
                          const TextStyle(
                        color:
                            Colors.white70,
                      ),
                    ),
                    trailing:
                        ElevatedButton(
                      onPressed: () =>
                          connect(
                        device,
                      ),
                      child:
                          const Text(
                        "Connect",
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
