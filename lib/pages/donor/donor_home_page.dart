import 'package:cibu/pages/donor/donor_dashboard_page.dart';
import 'package:flutter/material.dart';

class DonorHomePage extends StatefulWidget {
  const DonorHomePage({super.key});

  @override
  State<DonorHomePage> createState() => _DonorHomePageState();
}

class _DonorHomePageState extends State<DonorHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DonorDashboard(),
    const Placeholder()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _pages[_selectedIndex]
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard'
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile'
          ),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        }
      ),
    );
  }
}