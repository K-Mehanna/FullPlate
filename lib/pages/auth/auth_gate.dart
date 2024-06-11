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
      throw Exception("Error getting document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(context);
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<UserInfo>(
            future: getUserInfo(snapshot.data!.uid),
            builder: (context, userInfoSnapshot) {
              if (userInfoSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen(context);
              }

              if (userInfoSnapshot.hasError) {
                return _buildErrorScreen(context, userInfoSnapshot.error!);
              }

              if (userInfoSnapshot.hasData) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _navigateToCorrectPage(context, userInfoSnapshot.data!);
                });
                return _buildLoadingScreen(context);
              }

              return _buildErrorScreen(context, Exception("Unexpected error"));
            },
          );
        } else {
          return TitlePage();
        }
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, Object error) {
    return Scaffold(
      body: Center(
        child: Text("Error: $error"),
      ),
    );
  }

  void _navigateToCorrectPage(BuildContext context, UserInfo userInfo) {
    final Widget destination;

    switch ((userInfo.userType, userInfo.completedProfile)) {
      case (UserType.DONOR, true):
        destination = DonorHomePage();
      case (UserType.KITCHEN, true):
        destination = KitchenHomePage();
      case (UserType.DONOR, false):
        destination = DonorSignupPage();
      case (UserType.KITCHEN, false):
        destination = KitchenSignupPage();
      default:
        destination = TitlePage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }
}
