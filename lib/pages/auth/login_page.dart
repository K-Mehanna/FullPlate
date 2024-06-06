import 'package:cibu/pages/auth/donor_signup.dart';
import 'package:cibu/pages/auth/kitchen_signup.dart';
import 'package:cibu/pages/donor/donor_home_page.dart';
import 'package:cibu/pages/kitchen/kitchen_home_page.dart';
import 'package:cibu/widgets/custom_alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cibu/widgets/custom_text_field.dart';
import 'package:cibu/widgets/custom_button.dart';
import 'package:cibu/enums/user_type.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key, required this.userType, this.isLoggedIn = false});

  final UserType userType;
  final bool isLoggedIn;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool isSignUp = false;

  void initState() {
    super.initState();

    if (widget.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        verifyLoggedInUser(context);
      });
    }
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   verifyLoggedInUser(context);
    // });
  }

  void verifyLoggedInUser(BuildContext context) {
    if (widget.isLoggedIn) {
      userExists(
        widget.userType == UserType.DONOR ? 'donors' : 'kitchens',
        _auth.currentUser!.uid
      ).then((exists) {
        if (exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => widget.userType == UserType.DONOR
                ? DonorHomePage()
                : KitchenHomePage(),
            ),
          );
        } else {
          CustomAlertDialog(context, 'User not found. Check that you are registered as a ${widget.userType.value}');
          print("Error: User not found in database. Currently in ${widget.userType.value}");
          _auth.signOut();
        }
      });
    }
  }


  Future<bool> userExists(String dbName, String userId) async {
    print("A user just signed in!");
    DocumentSnapshot userDoc = await _db.collection(dbName).doc(userId).get();
    print("We're here now!");
    return userDoc.exists;
  }

  void signUserIn(BuildContext context) {
    _auth
      .signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      )
      .then((userCredential) => {}
        // userExists(
        //   widget.userType == UserType.DONOR ? 'donors' : 'kitchens',
        //   userCredential.user!.uid
        // )
        , onError: (e) => {
          if (e.code == 'invalid-email') {
            CustomAlertDialog(context, 'Invalid email'),
          } else if (e.code == 'user-not-found' || e.code == 'wrong-password') {
            CustomAlertDialog(context, 'Incorrect login credentials'),
          } else {
            CustomAlertDialog(context, 'Error: ${e.code}'),
          },
          print("Error: ${e.code}"),
        });
      // .then((exists) => {
      //   print("This is being run"),
      //   if (exists) {
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => widget.userType == UserType.DONOR
      //           ? DonorHomePage()
      //           : KitchenHomePage(),
      //       ),
      //     )
      //   } else {
      //     invalidMessage('User not found. Check that you are registered as a ${widget.userType.value}'),
      //     print("Error: User not found in database. Currently in ${widget.userType.value}"),
      //     _auth.signOut(),
      //   }
      // });
  }

  void signUserUp(BuildContext context) {
    _auth
      .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      )
      .then((_) => {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => widget.userType == UserType.DONOR
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
          title: Text('${widget.userType.value} Page'),
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
                    isSignUp ? 'Sign Up' : 'Sign In',
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

                  if (isSignUp) const SizedBox(height: 10),
                  if (isSignUp)
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

                  const SizedBox(height: 25),

                  CustomButton(
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        isSignUp ? signUserUp(context) : signUserIn(context);
                      }
                    },
                    text: isSignUp ? 'Sign Up' : 'Sign In',
                  ),

                  const SizedBox(height: 50),

                  // not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isSignUp
                            ? 'Already have an account?'
                            : 'Not a member?',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isSignUp = !isSignUp;
                          });
                        },
                        child: Text(
                          isSignUp ? 'Log In' : 'Register now',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
