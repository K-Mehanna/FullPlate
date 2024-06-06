import 'package:cibu/pages/auth/donor_signup.dart';
import 'package:cibu/pages/auth/kitchen_signup.dart';
import 'package:cibu/pages/auth/login_page.dart';
import 'package:cibu/widgets/custom_alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cibu/widgets/custom_text_field.dart';
import 'package:cibu/widgets/custom_button.dart';
import 'package:cibu/enums/user_type.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  var userType = UserType.DONOR;

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void signUserUp(BuildContext context) {
    _auth
      .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      )
      .then((_) => {
        _db.collection('users').doc(_auth.currentUser!.uid).set({
          'email': emailController.text,
          'userType': userType.value,
        }),
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => userType == UserType.DONOR
              ? DonorSignupPage()
              : KitchenSignupPage(),
          ),
        )}, onError: (e) => {
          if (e.code == 'invalid-email') {
            CustomAlertDialog(context, 'Invalid email'),
          } else if (e.code == 'email-already-in-use') {
            CustomAlertDialog(context, 'Email already in use'),
          } else if (e.code == 'weak-password') {
            CustomAlertDialog(context, 'Password is too weak'),
          } else {
            CustomAlertDialog(context, 'Error: ${e.code}'),
          },
          print("Error: ${e.code}"),
        }
      );
  }

  // wrong email message popup

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Signup Page'),
        ),
        body: SingleChildScrollView(
          //padding: const EdgeInsets.all(20),
          child: Center(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign Up',
                    style: Theme.of(context).textTheme.displayMedium!,
                  ),
                  const SizedBox(height: 40),

                  CustomTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  CustomTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  CustomTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                    validator: (value) {
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("I am a: ", style: Theme.of(context).textTheme.labelLarge!),
                        const SizedBox(width: 4),
                        SegmentedButton<UserType>(
                          segments: const <ButtonSegment<UserType>>[
                            ButtonSegment<UserType>(
                                value: UserType.DONOR,
                                label: Text('Donor'),
                            ),
                            ButtonSegment<UserType>(
                                value: UserType.KITCHEN,
                                label: Text('Kitchen'),
                            ),
                          ],
                          selected: <UserType>{userType},
                          onSelectionChanged: (Set<UserType> newSelection) {
                            setState(() {
                              userType = newSelection.first;
                            });
                          },
                        ),
                      ],
                    ),
                  ),


                  const SizedBox(height: 25),

                  CustomButton(
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        signUserUp(context);
                      }
                    },
                    text: 'Sign Up',
                  ),

                  const SizedBox(height: 50),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Divider(),

                  const SizedBox(height: 25),

                  CustomButton(
                    onTap: () {},
                    text: 'Sign Up with Google',
                  ),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
