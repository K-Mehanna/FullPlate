import 'dart:ui';

import 'package:cibu/pages/auth/login_page.dart';
import 'package:cibu/pages/auth/signup_page.dart';
import 'package:cibu/pages/map_screen.dart';
import 'package:cibu/pages/plain_map_screen.dart';
import 'package:cibu/widgets/custom_divider.dart';
import 'package:flutter/material.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    print("Title page build");

    final ThemeData theme = Theme.of(context);

    final TextStyle titleStyle = theme.textTheme.headlineLarge!.copyWith(
      color: theme.colorScheme.onSurface,
    );

    final ButtonStyle buttonTheme = ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 3,
    );

    return Scaffold(
      body: Stack(
        children: [
          PlainMapScreen(),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                color: theme.colorScheme.inversePrimary.withOpacity(0.25),
              ),
            ),
          ),
          Center(
            child: Card(
              elevation: 8.0,
              color: theme.colorScheme.surfaceContainer,
              child: IntrinsicWidth(
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Welcome to Cibu!", style: titleStyle),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: buttonTheme,
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
                                style: buttonTheme,
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
                          CustomDivider(),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: buttonTheme,
                            onPressed: () {
                              // Add your browse nearby places functionality here
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapScreen(),
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
