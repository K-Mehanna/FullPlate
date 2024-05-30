import 'package:cibu/pages/kitchen/kitchen_map_page.dart';
import 'package:cibu/pages/kitchen/kitchen_dashboard_page.dart';
import 'package:cibu/pages/kitchen/kitchen_profile_page.dart';
import 'package:flutter/material.dart';

class KitchenHomePage extends StatefulWidget {
  const KitchenHomePage({super.key});

  @override
  State<KitchenHomePage> createState() => _KitchenHomePageState();
}

class _KitchenHomePageState extends State<KitchenHomePage> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    KitchenDashboardPage(),
    KitchenMapPage(),
    KitchenProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.map), label: 'Profile'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          }),
    );
  }
}
