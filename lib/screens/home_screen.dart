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
      final msg = data["msg"] ?? "";

      // استقبال الشبكات من ESP
      if (msg.contains("Networks found")) {
        final lines = msg.split("\n");

        List<String> list = [];

        for (var l in lines) {
          if (l.contains(":")) {
            final name = l.split(":")[1].split("(")[0].trim();
            list.add(name);
          }
        }

        setState(() {
          networks = list;
        });

        return;
      }

      // استقبال الهجمات
      setState(() {
        _attacks.insert(0, {
          "type": "ATTACK",
          "ssid": currentNetwork,
          "desc": msg,
          "risk": 80,
        });
      });

      _showAlert(msg);
    });
  }

  void _showAlert(String msg) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🚨 تنبيه"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إغلاق"),
          ),
        ],
      ),
    );
  }

  void _generateTraffic() {
    final rand = Random();
    double change = rand.nextDouble() * 20 - 10;
    double newValue = (_lastValue + change).clamp(0, 100);
    _lastValue = newValue;

    setState(() {
      _trafficData.add(TrafficPoint(newValue));
      if (_trafficData.length > 30) _trafficData.removeAt(0);
    });
  }

  void _toggleRunning() {
    if (!BLEManager.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ غير متصل")),
      );
      return;
    }

    setState(() => _isRunning = !_isRunning);

    if (_isRunning) {
      BLEManager.send("monitor");
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _generateTraffic();
      });
    } else {
      BLEManager.send("stop");
      _timer?.cancel();
    }
  }

  void _showNetworks() {
    BLEManager.send("scan");

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return networks.isEmpty
            ? const Center(child: Text("جاري البحث..."))
            : ListView.builder(
                itemCount: networks.length,
                itemBuilder: (_, i) {
                  return ListTile(
                    title: Text(networks[i]),
                    onTap: () {
                      currentNetwork = networks[i];
                      BLEManager.send("select ${i + 1}");
                      setState(() {});
                      Navigator.pop(context);
                    },
                  );
                },
              );
      },
    );
  }

  Widget buildGraph() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true),
              spots: List.generate(
                _trafficData.length,
                (i) => FlSpot(i.toDouble(), _trafficData[i].value),
              ),
            ),
          ],
        ),
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
      appBar: AppBar(title: const Text("الرئيسية")),
      body: Column(
        children: [
          Text(BLEManager.isConnected ? "🟢 متصل" : "🔴 غير متصل"),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _toggleRunning,
                  child: Text(_isRunning ? "إيقاف" : "تشغيل"),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: _showNetworks,
                  child: Text(currentNetwork),
                ),
              ),
            ],
          ),

          buildGraph(),

          Expanded(
            child: ListView.builder(
              itemCount: _attacks.length,
              itemBuilder: (_, i) {
                final a = _attacks[i];
                return ListTile(
                  title: Text(a["desc"]),
                  subtitle: Text(a["ssid"]),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
