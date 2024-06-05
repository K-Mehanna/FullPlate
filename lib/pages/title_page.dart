import 'package:flutter/material.dart';
import 'package:cibu/pages/donor/donor_home_page.dart';
import 'package:cibu/pages/kitchen/kitchen_home_page.dart';
import 'package:cibu/enums/user_type.dart';
import 'package:cibu/pages/auth/auth_gate.dart';


class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Welcome to Cibu!", style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                Text(
                  "I am a",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UserButton(userType: UserType.DONOR),
                    SizedBox(width: 20),
                    UserButton(userType: UserType.KITCHEN),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserButton extends StatelessWidget {
  const UserButton({super.key, required this.userType});

  final UserType userType;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => 
              // userType == UserType.DONOR
              //     ? DonorHomePage()
              //     : KitchenHomePage()
              AuthGate(userType: userType)
          ),
        );
      },
      child: Text(userType.value),
    );
  }
}
