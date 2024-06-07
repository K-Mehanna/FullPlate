import 'dart:ui';

import 'package:cibu/pages/auth/login_page.dart';
import 'package:cibu/pages/auth/signup_page.dart';
import 'package:cibu/pages/map_screen.dart';
import 'package:cibu/widgets/custom_divider.dart';
import 'package:flutter/material.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final TextStyle titleStyle = theme.textTheme.headlineLarge!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
    );

    final ButtonStyle buttonTheme = ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
    );

    return Scaffold(
      body: Stack(
        children: [
          MapScreen(),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                color: theme.colorScheme.surfaceDim.withOpacity(0.5),
              ),
            ),
          ),
          Center(
            child: Card(
              elevation: 8.0,
              color: theme.colorScheme.primaryContainer,
              child: IntrinsicWidth(
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Welcome to Cibu!",
                            style: titleStyle
                          ),
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
                                child: Text(
                                  'Sign Up'
                                ),
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
