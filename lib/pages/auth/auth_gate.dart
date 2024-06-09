import 'package:cibu/pages/auth/donor_signup.dart';
import 'package:cibu/pages/auth/kitchen_signup.dart';
import 'package:cibu/pages/donor/donor_home_page.dart';
import 'package:cibu/pages/kitchen/kitchen_home_page.dart';
import 'package:cibu/pages/title_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import 'package:flutter/material.dart';
import 'package:cibu/enums/user_type.dart';
import 'package:cibu/models/user_info.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<UserInfo> getUserInfo(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      return UserInfo.fromFirestore(docSnapshot);
    } catch (e) {
      print("Error getting document: $e");

      //await FirebaseAuth.instance.signOut();

      // maybe this might work
      throw Exception("Error getting document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    print("AuthGate build");

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        print(
            "Snapshot Updated!: snapshot.hasData: ${snapshot.hasData}, snapshot.data is null: ${snapshot.data == null}");
        if (snapshot.hasData && snapshot.data != null) {
          getUserInfo(snapshot.data!.uid).then((userInfo) {
            // switch ((userInfo.userType, userInfo.completedProfile)) {
            //   case (UserType.DONOR, true):    return DonorHomePage();
            //   case (UserType.KITCHEN, true):  return KitchenHomePage();
            //   case (UserType.DONOR, false):   return DonorSignupPage();
            //   case (UserType.KITCHEN, false): return KitchenSignupPage();
            // }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) {
                switch ((userInfo.userType, userInfo.completedProfile)) {
                  case (UserType.DONOR, true):
                    return DonorHomePage();
                  case (UserType.KITCHEN, true):
                    return KitchenHomePage();
                  case (UserType.DONOR, false):
                    return DonorSignupPage();
                  case (UserType.KITCHEN, false):
                    return KitchenSignupPage();
                }
              }),
            );
          });
          return Container(
            color: theme.colorScheme.surface,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
          //CircularProgressIndicator();
        } else {
          return TitlePage();
        }
      },
    );
  }
}
