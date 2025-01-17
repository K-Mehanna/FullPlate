// ignore_for_file: dead_code

import 'package:cibu/firebase_options.dart';
import 'package:cibu/pages/auth/auth_gate.dart';
import 'package:cibu/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // run this command:
  // firebase emulators:start --import ./emulators_data --export-on-exit
  // set to true to use emulator
  bool useEmulator = false;

  if (useEmulator) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      print('Connected to emulator');
    } catch (e) {
      // ignore: avoid_print
      print(e);
      print('Error on connecting to emulator');
    }
  } else {
    print('Emulator disabled');
  }
  await FirebaseAuth.instance.signOut();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FullPlate',
      debugShowCheckedModeBanner: false,
      theme: MaterialTheme(Typography.blackCupertino).lightMediumContrast(),
      //darkTheme: MaterialTheme(Typography.blackCupertino).dark(),
      home: AuthGate(),
    );
  }
}
