import 'package:flutter/material.dart';
import '../ble_manager.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() =>
      _StatisticsScreenState();
}

class _StatisticsScreenState
    extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    final attacks = BLEManager.attacks;

    int totalAttacks = attacks.length;

    int highRisk = attacks
        .where((e) => (e["risk"] ?? 0) >= 80)
        .length;

    return Scaffold(
      backgroundColor:
          const Color(0xFF0B1A2A),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0B1A2A),
        centerTitle: true,
        title: const Text(
          "الإحصائيات",
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    const Color(0xFF132C45),
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "إجمالي الهجمات",
                    style: TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "$totalAttacks",
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 30,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    const Color(0xFF132C45),
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "الهجمات عالية الخطورة",
                    style: TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "$highRisk",
                    style:
                        const TextStyle(
                      color: Colors.red,
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Expanded(
              child: attacks.isEmpty
                  ? const Center(
                      child: Text(
                        "لا توجد بيانات حالياً",
                        style:
                            TextStyle(
                          color: Colors
                              .white70,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount:
                          attacks.length,
                      itemBuilder:
                          (_, i) {
                        final attack =
                            attacks[i];

                        return Card(
                          color:
                              const Color(
                            0xFF132C45,
                          ),
                          child:
                              ListTile(
                            leading:
                                const Icon(
                              Icons
                                  .analytics,
                              color: Colors
                                  .cyan,
                            ),
                            title:
                                Text(
                              attack["type"]
                                  .toString(),
                              style:
                                  const TextStyle(
                                color: Colors
                                    .white,
                              ),
                            ),
                            subtitle:
                                Text(
                              attack["ssid"]
                                  .toString(),
                              style:
                                  const TextStyle(
                                color: Colors
                                    .white70,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
