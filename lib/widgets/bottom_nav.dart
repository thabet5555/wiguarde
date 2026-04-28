import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isArabic;

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isArabic,
  });

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
          ),
        ],
      ),

      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,

        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey,

        showSelectedLabels: true,
        showUnselectedLabels: false,

        selectedIconTheme: const IconThemeData(
          size: 28,
          color: Color(0xFF1E88E5),
        ),

        unselectedIconTheme: const IconThemeData(
          size: 22,
        ),

        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: t("الرئيسية", "Home"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bluetooth),
            label: t("بلوتوث", "Bluetooth"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt),
            label: t("التقارير", "Reports"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.security),
            label: t("الهجمات", "Attacks"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: t("الإحصائيات", "Stats"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: t("الإعدادات", "Settings"),
          ),
        ],
      ),
    );
  }
}