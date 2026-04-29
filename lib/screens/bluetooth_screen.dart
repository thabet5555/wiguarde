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
    scan();
  }

  void scan() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        devices = results
            .where((r) => r.device.platformName.isNotEmpty)
            .toList();
      });
    });
  }

  void connect(BluetoothDevice d) async {
    await BLEManager.connect(d);

    widget.onConnected(d, d.characteristics.isNotEmpty
        ? d.characteristics.first
        : BluetoothCharacteristic(
            remoteId: d.remoteId,
            serviceUuid: Guid("0000"),
            characteristicUuid: Guid("0000"),
            descriptors: [],
            properties: CharacteristicProperties(),
          ));
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
            title: Text(d.platformName),
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
