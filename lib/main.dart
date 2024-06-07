import 'package:cibu/firebase_options.dart';
import 'package:cibu/pages/auth/auth_gate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // run this command:
  // firebase emulators:start --import ./emulators_data --export-on-exit
  // if (kDebugMode) {
  //   try {
  //     FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  //     await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //     print('Connected to emulator');
  //   } catch (e) {
  //     // ignore: avoid_print
  //     print(e);
  //     print('Error on connecting to emulator');
  //   }
  // } else {
  //   print('Emulator disabled');
  // }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cibu',
      debugShowCheckedModeBanner: false,
      theme: MaterialTheme(Typography.blackCupertino).light(),
      // ThemeData(
      //   useMaterial3: true,
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      // ),
      home: AuthGate(),
    );
  }
}
