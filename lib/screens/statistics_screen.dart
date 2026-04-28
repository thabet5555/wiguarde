import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attacks = [
      "Deauth",
      "Fake AP",
      "Sniff",
      "MAC Spoof",
      "Evil Twin",
      "ARP",
      "Flood",
      "Probe",
    ];

    final values = [8, 5, 6, 4, 7, 3, 2, 6];

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.teal,
      Colors.brown,
      Colors.indigo,
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("الإحصائيات"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "يعرض هذا القسم تحليل الهجمات المكتشفة من الشبكة باستخدام النظام.",
                  style: TextStyle(fontSize: 13),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: BarChart(
                  BarChartData(
                    maxY: 10,
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),

                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 2,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();

                            if (index < 0 || index >= attacks.length) {
                              return const SizedBox();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                attacks[index],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 9),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    barGroups: List.generate(attacks.length, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: values[i].toDouble(),
                            width: 14,
                            color: colors[i],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "كل عمود يمثل عدد الهجمات المكتشفة لكل نوع من أنواع الهجمات.",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}