import 'package:cibu/pages/auth/auth2/title_page2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DonorProfilePage extends StatefulWidget {
  const DonorProfilePage({super.key});

  @override
  State<DonorProfilePage> createState() => _DonorProfilePageState();
}

class _DonorProfilePageState extends State<DonorProfilePage> {
  void _signOut() {
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TitlePage2()
        ),
      );
    });
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => TitlePage()
    //   ),
    // );  
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
