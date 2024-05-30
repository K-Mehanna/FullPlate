import 'package:cibu/pages/kitchen/kitchen_dashboard_page.dart';
import 'package:cibu/pages/kitchen/kitchen_map_page.dart';
import 'package:cibu/pages/kitchen/kitchen_profile_page.dart';
import 'package:flutter/material.dart';

class TabBarDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Shush'),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                Tab(icon: Icon(Icons.map), text: 'Map'),
                Tab(icon: Icon(Icons.person), text: 'Profile'),
              ],
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              KitchenDashboardPage(),
              KitchenMapPage(),
              KitchenProfilePage()
            ],
          ),
        );
      }),
    );
  }
}
