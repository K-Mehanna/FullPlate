import 'package:cibu/pages/donor/donor_home_page.dart';
import 'package:cibu/pages/kitchen/kitchen_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cibu/pages/auth/login_page.dart';
import 'package:cibu/enums/user_type.dart';

class AuthGate extends StatelessWidget {
  final UserType userType;
  const AuthGate({super.key, required this.userType});

  Future<bool> userExists(String dbName, String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(dbName).doc(userId).get();
    return userDoc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            User? user = snapshot.data;
            if (user == null) {
              return LoginPage(userType: userType);
            }

            return FutureBuilder<bool>(
              future: userExists(userType == UserType.DONOR ? 'donors' : 'kitchens', user.uid),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!) {
                  return LoginPage(userType: userType);
                }
                return userType == UserType.DONOR
                    ? DonorHomePage()
                    : KitchenHomePage();
              },
            );
          } else {
            return LoginPage(userType: userType);
          }
        },
      ),
    );
  }
}
