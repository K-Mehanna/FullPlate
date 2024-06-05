import 'package:cibu/pages/auth/donor_signup.dart';
import 'package:cibu/pages/auth/kitchen_signup.dart';
import 'package:cibu/pages/donor/donor_home_page.dart';
import 'package:cibu/pages/kitchen/kitchen_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cibu/widgets/custom_text_field.dart';
import 'package:cibu/widgets/custom_button.dart';
import 'package:cibu/enums/user_type.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key, required this.userType});

  final UserType userType;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isSignUp = false;

  // sign user in method
  void signUserIn() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // pop the loading circle
      Navigator.pop(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.userType == UserType.DONOR
                  ? DonorHomePage()
                  : KitchenHomePage()),
      );

    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);
      // WRONG EMAIL
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        // show error to user
        invalidMessage('Invalid Login Credentials');
      } else {
        // show error to user
        invalidMessage('Error: ${e.code}');
      }
      print("Error: ${e.code}");
    }
  }

  void signUserUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // try sign up
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // pop the loading circle
      Navigator.pop(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.userType == UserType.DONOR
                  ? DonorSignupPage()
                  : KitchenSignupPage()),
      );
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);
      // WRONG EMAIL
      if (e.code == 'weak-password') {
        // show error to user
        invalidMessage('Password is too weak');
      } else if (e.code == 'email-already-in-use') {
        // show error to user
        invalidMessage('Email already in use');
      } else {
        // show error to user
        invalidMessage('Error: ${e.code}');
      }
      print("Error: ${e.code}");
    }
  }

  // wrong email message popup
  void invalidMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

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
        body: Center(
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
                if (isSignUp) CustomTextField(
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
                      isSignUp ? signUserUp() : signUserIn();
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
                      !isSignUp ? 'Not a member?' : 'Already have an account?',
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
                        !isSignUp ? 'Register now' : 'Log In',
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
    );
  }
}