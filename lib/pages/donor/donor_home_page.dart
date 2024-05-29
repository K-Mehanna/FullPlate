import 'package:flutter/material.dart';

class DonorHomePage extends StatelessWidget {
  const DonorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Donor home page")
      ),
      body: Center(
        child: Text("This is the donor home page")
      )
    );
  }
}