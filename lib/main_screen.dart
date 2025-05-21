import 'package:flutter/material.dart';
import 'package:snaptext_ai/constants/colors.dart';
import 'package:snaptext_ai/screens/home_page.dart';
import 'package:snaptext_ai/screens/user_history.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Method to handle the bottom navigation bar item tap
  void _onTapItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.transform),
            label: "Conversions",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
        onTap: _onTapItem,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 3, 42, 34),
        unselectedItemColor: const Color.fromARGB(255, 252, 254, 255),
        backgroundColor: mainColor,
      ),
      body: _selectedIndex == 0 ? const HomeScreen() : const UserHistory(),
    );
  }
}
