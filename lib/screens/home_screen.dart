import 'package:flutter/material.dart';
import '../ble_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {

    final attacks =
        BLEManager.attacks;

    final networks =
        BLEManager.networks;

    return Scaffold(
      backgroundColor:
          const Color(0xFF0B1A2A),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0B1A2A),
        centerTitle: true,
        title: const Text(
          "لوحة الحماية الذكية",
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(15),
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                15,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFF132C45,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  15,
                ),
              ),
              child: Column(
                children: [

                  Text(
                    BLEManager
                            .isConnected
                        ? "🟢 الجهاز متصل"
                        : "🔴 الجهاز غير متصل",
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    BLEManager
                            .currentNetwork
                            .isEmpty
                        ? "لا توجد شبكة حالياً"
                        : BLEManager
                            .currentNetwork,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color: Colors
                          .white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Row(
              children: [

                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        BLEManager
                                .isConnected
                            ? () async {
                                await BLEManager
                                    .startScan();

                                if (mounted) {
                                  setState(
                                      () {});
                                }
                              }
                            : null,
                    icon: const Icon(
                      Icons
                          .play_arrow,
                    ),
                    label:
                        const Text(
                      "بدء الفحص",
                    ),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        BLEManager
                                .isConnected
                            ? () async {
                                await BLEManager
                                    .stopScan();

                                if (mounted) {
                                  setState(
                                      () {});
                                }
                              }
                            : null,
                    icon: const Icon(
                      Icons.stop,
                    ),
                    label:
                        const Text(
                      "إيقاف الفحص",
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 15,
            ),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                12,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFF132C45,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  15,
                ),
              ),
              child: Text(
                "عدد الشبكات المكتشفة: ${networks.length}",
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                12,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFF132C45,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  15,
                ),
              ),
              child: Text(
                "عدد الهجمات المكتشفة: ${attacks.length}",
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Expanded(
              child: networks
                      .isEmpty
                  ? const Center(
                      child: Text(
                        "اضغط بدء الفحص لعرض الشبكات",
                        style:
                            TextStyle(
                          color: Colors
                              .white70,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount:
                          networks
                              .length,
                      itemBuilder:
                          (_, i) {
                        return Card(
                          color:
                              const Color(
                            0xFF132C45,
                          ),
                          child:
                              ListTile(
                            leading:
                                const Icon(
                              Icons.wifi,
                              color: Colors
                                  .green,
                            ),
                            title:
                                Text(
                              networks[
                                  i],
                              style:
                                  const TextStyle(
                                color: Colors
                                    .white,
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
