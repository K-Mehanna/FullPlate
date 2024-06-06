import 'package:cibu/pages/donor/donor_home_page.dart';
import 'package:cibu/pages/kitchen/kitchen_home_page.dart';
import 'package:cibu/widgets/custom_alert_dialog.dart';
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
          //return LoginPage(userType: userType);
          if (snapshot.hasData) {
            User? user = snapshot.data;
            if (user == null) {
              return LoginPage(userType: userType);
            } else {
              userExists(userType == UserType.DONOR ? 'donors' : 'kitchens', user.uid).then((exists) {
                if (!exists) {
                  CustomAlertDialog(context, 'User not found. Check that you are registered as a ${userType.value}');
                  print("Error: User not found in database. Currently in ${userType.value}");
                  FirebaseAuth.instance.signOut().then((_) => LoginPage(userType: userType));
                  //return LoginPage(userType: userType);
                } else {
                  return userType == UserType.DONOR
                    ? DonorHomePage()
                    : KitchenHomePage();
                }
              });

              throw Exception("MR BALLS: User not found in database. Currently in ${userType.value}");
            }

            // return FutureBuilder<bool>(
            //   future: userExists(userType == UserType.DONOR ? 'donors' : 'kitchens', user.uid),
            //   builder: (context, userSnapshot) {
            //     if (userSnapshot.connectionState == ConnectionState.waiting) {
            //       return Center(child: CircularProgressIndicator());
            //     }
            //     if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!) {
            //       if (!userSnapshot.data!) {
            //         CustomAlertDialog(context, 'User not found. Check that you are registered as a ${userType.value}');
            //         print("Error: User not found in database. Currently in ${userType.value}");
            //         FirebaseAuth.instance.signOut();
            //       }
            //       return LoginPage(userType: userType);
            //     }
            //     return userType == UserType.DONOR
            //       ? DonorHomePage()
            //       : KitchenHomePage();
            //   },
            // );
          } else {
            print("No login data available");
            return LoginPage(userType: userType);
          }
        },
      ),
    );
  }
}
