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

    BLEManager.setListener((msg) {

      // ✅ استقبال الشبكات من ESP
      if (msg.contains("Networks found")) {
        final lines = msg.split("\n");

        setState(() {
          networks = lines
              .where((l) => l.contains(":"))
              .map((l) => l.split(":")[1].split("(")[0].trim())
              .toList();
        });

        return;
      }

      // ✅ استقبال الهجمات
      setState(() {
        _attacks.insert(0, {
          "type": msg,
          "ssid": currentNetwork,
          "risk": 50,
        });
      });
    });
  }

  void _generateTraffic() {
    final rand = Random();
    double change = rand.nextDouble() * 20 - 10;
    double newValue = (_lastValue + change).clamp(0, 100);
    _lastValue = newValue;

    setState(() {
      _trafficData.add(TrafficPoint(newValue));
      if (_trafficData.length > 30) {
        _trafficData.removeAt(0);
      }
    });
  }

  void _toggleRunning() {
    if (!BLEManager.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ لم يتم الاتصال بالبلوتوث")),
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
    if (!BLEManager.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ لازم تتصل بالجهاز أول")),
      );
      return;
    }

    // ✅ طلب الشبكات من ESP
    BLEManager.send("scan");

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return networks.isEmpty
            ? const Center(child: Text("جاري البحث عن الشبكات..."))
            : ListView(
                children: networks.map((n) {
                  return ListTile(
                    leading: const Icon(Icons.wifi),
                    title: Text(n),
                    onTap: () {
                      int index = networks.indexOf(n) + 1;

                      setState(() {
                        currentNetwork = n;
                      });

                      // ✅ اختيار الشبكة
                      BLEManager.send("select $index");

                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              );
      },
    );
  }

  Widget buildGraph() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(14),
      ),
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
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.15),
              ),
              spots: List.generate(_trafficData.length, (i) {
                return FlSpot(i.toDouble(), _trafficData[i].value);
              }),
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
      appBar: AppBar(
        title: const Text("لوحة الحماية الذكية"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          Text(
            BLEManager.isConnected ? "🟢 متصل" : "⚠️ غير متصل",
            style: const TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleRunning,
                    child: Text(_isRunning ? "إيقاف" : "بدء"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showNetworks,
                    child: Text(currentNetwork),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: const Text("الهجمات المكتشفة"),
              trailing: Text(
                "${_attacks.length}",
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),

          buildGraph(),

          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "آخر الهجمات",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _attacks.length,
              itemBuilder: (_, i) {
                final a = _attacks[i];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.orange),
                    title: Text(a["type"]),
                    subtitle: Text(a["ssid"]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
