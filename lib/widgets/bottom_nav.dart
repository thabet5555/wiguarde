import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final bool isArabic;
  final Function(int) onItemTapped;

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.isArabic,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1E1E2E),
      selectedItemColor: Colors.cyan,
      unselectedItemColor: Colors.white70,
      onTap: onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.bluetooth), label: 'Bluetooth'),
        BottomNavigationBarItem(icon: Icon(Icons.report), label: 'التقارير'),
        BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'الهجمات'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'الإحصائيات'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
      ],
    );
  }
}
