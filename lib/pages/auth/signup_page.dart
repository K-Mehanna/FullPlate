import 'package:cibu/pages/auth/donor_signup.dart';
import 'package:cibu/pages/auth/kitchen_signup.dart';
import 'package:cibu/pages/auth/login_page.dart';
import 'package:cibu/widgets/custom_alert_dialog.dart';
import 'package:cibu/widgets/custom_divider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cibu/widgets/custom_text_field.dart';
import 'package:cibu/widgets/custom_button.dart';
import 'package:cibu/enums/user_type.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<void> signUpWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    try {
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo!.isNewUser) {
        try {
          await _db.collection('users').doc(_auth.currentUser!.uid).set({
            'email': _auth.currentUser!.email,
            'userType': userType.value,
            'completedProfile': false,
          }).then((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => userType == UserType.DONOR
                    ? DonorSignupPage()
                    : KitchenSignupPage(),
              ),
            );
          });
        } catch (e) {
          print("User Sign Up With Google");
        }
      }
      // else sign is as usual
      
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'account-exists-with-different-credential') {
          CustomAlertDialog(context, 'Account exists with other credentials (email)');
        } else if (e.code == 'invalid-credential') {
          CustomAlertDialog(context, 'Invalid credentials');
        } else {
          CustomAlertDialog(context, 'Error: ${e.code}');
        }
      }
      print("Error: ${e.code}");
    }
  }

  Future<void> signUserUp(BuildContext context) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      try {
        await _db.collection('users').doc(_auth.currentUser!.uid).set({
          'email': emailController.text,
          'userType': userType.value,
          'completedProfile': false,
        }).then((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => userType == UserType.DONOR
                  ? DonorSignupPage()
                  : KitchenSignupPage(),
            ),
          );
        });
      } catch (e) {
        print("User Sign Up");
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'invalid-email') {
          CustomAlertDialog(context, 'Invalid email');
        } else if (e.code == 'email-already-in-use') {
          CustomAlertDialog(context, 'Email already in use');
        } else if (e.code == 'weak-password') {
          CustomAlertDialog(context, 'Password is too weak');
        } else {
          CustomAlertDialog(context, 'Error: ${e.code}');
        }
      }
      print("Error: ${e.code}");
    }
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
            //title: Text('Signup Page'),
            ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
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
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("I am a: ",
                          style: Theme.of(context).textTheme.labelLarge!),
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
                  const SizedBox(height: 25),
                  CustomButton(
                    onTap: () async {
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
                  CustomDivider(),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () async {
                      await signUpWithGoogle(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Background color
                      foregroundColor: Colors.black, // Text color
                      side: BorderSide(color: Colors.grey), // Border color
                      padding: EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      //mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage('lib/assets/google.png'),
                          fit: BoxFit.cover,
                          height: 36.0,
                        ),  
                        SizedBox(width: 12.0),
                        Text(
                          'Sign Up with Google',
                          style: Theme.of(context).textTheme.titleLarge!,
                        ),
                      ],
                    ),
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
