import 'package:cibu/pages/donor/donor_home_page.dart';
import 'package:cibu/pages/kitchen/kitchen_home_page.dart';
import 'package:cibu/pages/title_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cibu/enums/user_type.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<UserType> getUserType(String userId) async {
    // Assuming 'users' is the collection name in Firestore
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
      final data = docSnapshot.data()! as Map<String, dynamic>;
      return UserTypeExtension.fromString(data['userType']!);
    } catch (e) {
      throw Exception("Error getting document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          getUserType(snapshot.data!.uid).then((value) {
            if (value == UserType.DONOR) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DonorHomePage()),
              );
            } else if (value == UserType.KITCHEN) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => KitchenHomePage()),
              );
            } else {
              throw Exception("Invalid user type: $value");
            }
          });
          return CircularProgressIndicator();
          //throw Exception("Error getting user type");
        } else {
          return TitlePage();
        }
      },
    );
  }
}
