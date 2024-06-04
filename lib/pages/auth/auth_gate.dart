import 'package:cibu/pages/donor/donor_home_page.dart';
import 'package:cibu/pages/kitchen/kitchen_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cibu/pages/auth/login_page.dart';
import 'package:cibu/enums/user_type.dart';

class AuthGate extends StatelessWidget {
  final UserType userType;
  const AuthGate({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            return userType == UserType.DONOR
                ? DonorHomePage()
                : KitchenHomePage();
          } else {
            return LoginPage(userType: userType);
          }
        },
      ),
    );
  }
}
