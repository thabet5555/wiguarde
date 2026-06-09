import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../ble_manager.dart';

const String SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
const String RX_UUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"; // كتابة الأوامر
const String TX_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"; // استقبال الإشعارات

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
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndStart();
  }

  Future<void> _requestPermissionsAndStart() async {
    // طلب كل الأذونات الممكنة للبلوتوث والموقع
    await [
      Permission.locationWhenInUse,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    // انتظار لحظة حتى تظهر الأذونات في النظام
    await Future.delayed(const Duration(milliseconds: 500));

    // بدء البحث تلقائياً
    startScan();
  }

  Future<void> startScan() async {
    // إيقاف أي بحث سابق وتنظيف
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();

    setState(() {
      isScanning = true;
      devices.clear();
    });

    // الاستماع لنتائج البحث
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;
      // نعرض جميع الأجهزة التي لها اسم (أو نرشح لاسم ESP32 إن أردت)
      final filtered = results.where((r) => r.device.platformName.isNotEmpty).toList();
      setState(() {
        devices = filtered;
      });
    }, onError: (error) {
      print("خطأ في البحث: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ: $error")),
        );
        setState(() => isScanning = false);
      }
    });

    // بدء البحث الفعلي مع مدة زمنية
    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 30),
        androidLegacy: true, // ضروري لأجهزة ESP32
      );
      // بعد انتهاء المهلة أوقف حالة البحث
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted && isScanning) {
          setState(() => isScanning = false);
        }
      });
    } catch (e) {
      print("فشل بدء البحث: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل البدء: $e")),
        );
        setState(() => isScanning = false);
      }
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    setState(() => isScanning = false);
  }

  Future<void> connect(BluetoothDevice device) async {
    if (isConnecting) return;
    setState(() => isConnecting = true);

    try {
      await device.connect(timeout: const Duration(seconds: 15));
      final services = await device.discoverServices();

      BluetoothCharacteristic? txChar;
      BluetoothCharacteristic? rxChar;

      for (final service in services) {
        if (service.uuid.toString().toUpperCase() == SERVICE_UUID) {
          for (final c in service.characteristics) {
            final uuid = c.uuid.toString().toUpperCase();
            if (uuid == TX_UUID) txChar = c;
            if (uuid == RX_UUID) rxChar = c;
          }
          break;
        }
      }

      if (txChar == null || rxChar == null) {
        throw Exception("الخدمة المطلوبة غير موجودة");
      }

      await txChar!.setNotifyValue(true);
      widget.onConnected(device, txChar, rxChar);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ متصل بـ ${device.platformName}")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ فشل الاتصال: $e")),
      );
      try { await device.disconnect(); } catch (_) {}
    } finally {
      if (mounted) setState(() => isConnecting = false);
    }
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    super.dispose();
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
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("جاري البحث...", style: TextStyle(color: Colors.white70)),
                  Text("تأكد من تفعيل GPS والبلوتوث", style: TextStyle(fontSize: 12, color: Colors.white54)),
                ],
              ),
            )
          : devices.isEmpty
              ? const Center(
                  child: Text(
                    "لا توجد أجهزة. تأكد من:\n- تشغيل جهاز ESP32\n- تفعيل Bluetooth والموقع\n- الضغط على زر التحديث",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (_, i) {
                    final d = devices[i].device;
                    return Card(
                      color: const Color(0xFF1E1E2E),
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.bluetooth, color: Colors.blue),
                        title: Text(
                          d.platformName.isEmpty ? "جهاز غير معروف" : d.platformName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(d.remoteId.str, style: const TextStyle(color: Colors.white70)),
                        trailing: ElevatedButton(
                          onPressed: isConnecting ? null : () => connect(d),
                          child: isConnecting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text("اتصل"),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
