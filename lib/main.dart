import 'package:cibu/firebase_options.dart';
import 'package:cibu/pages/auth/auth2/main2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'pages/title_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp2());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cibu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: TitlePage(),
    );
  }
}
