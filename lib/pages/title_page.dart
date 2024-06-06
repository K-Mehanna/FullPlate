import 'dart:ui';

import 'package:cibu/pages/auth/login_page.dart';
import 'package:cibu/pages/auth/signup_page.dart';
import 'package:cibu/pages/map_screen.dart';
import 'package:flutter/material.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapScreen(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 100, // height of the blur area
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: Colors.black.withOpacity(0), // transparent color
                ),
              ),
            ),
          ),
          Center(
            child: Card(
              elevation: 8.0,
              child: IntrinsicWidth(
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Welcome to Cibu!", style: TextStyle(fontSize: 24)),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpPage(),
                                    ),
                                  );
                                },
                                child: Text('Sign Up'),
                              ),
                              SizedBox(width: 10.0),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(),
                                    ),
                                  );
                                },
                                child: Text('Login'),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 20.0),
                                child: Divider(
                                  color: Colors.black,
                                )),
                            ),
                            Text("OR"),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 20.0),
                                child: Divider(
                                  color: Colors.black,
                                )),
                            ),
                          ]),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Add your browse nearby places functionality here
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapScreen(hasAppBar: true,),
                                ),
                              );
                            },
                            child: Text('Browse Nearby Places'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
