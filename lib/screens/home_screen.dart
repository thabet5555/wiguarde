import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../ble_manager.dart';

class TrafficPoint {
  final double value;
  TrafficPoint(this.value);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRunning = false;

  String currentNetwork = 'لم يتم الاختيار';
  List<String> networks = [];

  final List<Map<String, dynamic>> _attacks = [];
  final List<TrafficPoint> _trafficData = [];

  Timer? _timer;
  double _lastValue = 50;

  @override
  void initState() {
    super.initState();

    BLEManager.setListener((data) {
      print("APP JSON: $data");

      // 📡 الشبكات
      if (data["cmd"] == "WIFI_LIST") {
        final List list = data["list"] ?? [];

        setState(() {
          networks = list.map((e) => e.toString()).toList();
        });

        return;
      }

      // 🚨 الهجمات
      final attack = {
        "ssid": data["ssid"] ?? "ESP32",
        "desc": data["msg"] ?? "",
        "type": data["cmd"] ?? "UNKNOWN",
        "risk": int.tryParse(data["risk"].toString()) ?? 50,
        "time": TimeOfDay.now().format(context),
        "date": DateTime.now().toString().substring(0, 10),
      };

      setState(() {
        _attacks.insert(0, attack);
      });
    });
  }

  void _toggleRunning() {
    if (!BLEManager.isConnected) return;

    setState(() => _isRunning = !_isRunning);

    if (_isRunning) {
      BLEManager.send("SCAN_WIFI");

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final rand = Random();
        double v = (_lastValue + rand.nextDouble() * 10 - 5)
            .clamp(0, 100);
        _lastValue = v;

        setState(() {
          _trafficData.add(TrafficPoint(v));
          if (_trafficData.length > 30) {
            _trafficData.removeAt(0);
          }
        });
      });
    } else {
      BLEManager.send("STOP_SCAN");
      _timer?.cancel();
    }
  }

  void _showNetworks() {
    if (!BLEManager.isConnected) return;

    networks.clear();

    BLEManager.send("GET_WIFI");

    showModalBottomSheet(
      context: context,
      builder: (_) => networks.isEmpty
          ? const Center(child: Text("جاري تحميل الشبكات..."))
          : ListView(
              children: networks.map((n) {
                return ListTile(
                  title: Text(n),
                  onTap: () {
                    setState(() => currentNetwork = n);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
    );
  }

  Widget graph() {
    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: List.generate(_trafficData.length, (i) {
              return FlSpot(i.toDouble(), _trafficData[i].value);
            }),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Column(
        children: [
          Text(BLEManager.isConnected
              ? "🟢 متصل"
              : "❌ غير متصل"),
          ElevatedButton(
            onPressed: _toggleRunning,
            child: Text(_isRunning ? "إيقاف" : "تشغيل"),
          ),
          ElevatedButton(
            onPressed: _showNetworks,
            child: Text(currentNetwork),
          ),
          SizedBox(height: 200, child: graph()),
        ],
      ),
    );
  }
}
