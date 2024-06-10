import 'package:cibu/pages/kitchen/kitchen_dashboard_page.dart';
import 'package:cibu/pages/kitchen/kitchen_map_page.dart';
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

  void onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // child: _pages[_selectedIndex],
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
          onDestinationSelected: onTapped),
    );
  }
}
