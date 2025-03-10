import 'package:flutter/material.dart';
import 'package:samosvulator/presentation/screens/home_screen.dart';
import 'package:samosvulator/presentation/screens/history_screen.dart';

import '../../core/network/dio_client.dart';

class MainScreen extends StatefulWidget {
  final DioClient dioClient;

  const MainScreen({super.key, required this.dioClient});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(dioClient: widget.dioClient),
      HistoryScreen(dioClient: widget.dioClient),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Расчёт'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'История'),
        ],
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}