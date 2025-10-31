import 'package:flutter/material.dart';

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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.reviews), label: 'Reseñas'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Reservas'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
      selectedItemColor: accent,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 8,
    );
  }
}
