import 'package:flutter/material.dart';
import '../i18n.dart';

class NavigatorBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  NavigatorBar({required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    // Use a light background and purple accent for the selected item to match the provided design
    const accent = Color(0xFF7C3AED); // purple-ish
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: selectedIndex,
      onTap: onItemSelected,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home), label: tr('nav.home')),
        BottomNavigationBarItem(icon: const Icon(Icons.reviews), label: tr('nav.reviews')),
        BottomNavigationBarItem(icon: const Icon(Icons.list), label: tr('nav.reservations')),
        BottomNavigationBarItem(icon: const Icon(Icons.person), label: tr('nav.profile')),
      ],
      selectedItemColor: accent,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 8,
    );
  }
}
