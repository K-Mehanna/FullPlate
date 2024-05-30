import 'package:cibu/pages/title_page.dart';
import 'package:flutter/material.dart';

class DonorProfilePage extends StatefulWidget {
  const DonorProfilePage({super.key});

  @override
  State<DonorProfilePage> createState() => _DonorProfilePageState();
}

class _DonorProfilePageState extends State<DonorProfilePage> {
  void _signOut() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TitlePage()
      ),
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
          )
        )
      ),
    );
  }
}
