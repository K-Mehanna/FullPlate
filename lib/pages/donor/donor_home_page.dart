import 'package:cibu/pages/donor/donor_dashboard_page.dart';
import 'package:cibu/pages/donor/donor_profile_page.dart';
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
    DonorProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    print("Reached the donor home page");
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        //_pages[_selectedIndex]
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.colorScheme.surfaceDim.withOpacity(0.5),
              blurRadius: 5,
            ),
          ],
        ),
        child: NavigationBar(
          elevation: 10,
          surfaceTintColor: Theme.of(context).colorScheme.inversePrimary,
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
      ),
    );
  }
}