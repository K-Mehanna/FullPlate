import 'package:cibu/pages/title_page.dart';
import 'package:flutter/material.dart';

class KitchenProfilePage extends StatefulWidget {
  const KitchenProfilePage({super.key});

  @override
  State<KitchenProfilePage> createState() => _KitchenProfilePageState();
}

class _KitchenProfilePageState extends State<KitchenProfilePage> {
  void _signOut() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TitlePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Center(
          child: ElevatedButton(
              onPressed: _signOut,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Sign Out"),
              ))),
    );
  }
}
