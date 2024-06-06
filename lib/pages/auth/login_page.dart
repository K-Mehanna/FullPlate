import 'package:cibu/pages/auth/signup_page.dart';
import 'package:cibu/widgets/custom_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cibu/widgets/custom_text_field.dart';
import 'package:cibu/widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  Future<void> signUserIn(BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'invalid-email') {
          CustomAlertDialog(context, 'Invalid email');
        } else if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          CustomAlertDialog(context, 'Incorrect login credentials');
        } else {
          CustomAlertDialog(context, 'Error: ${e.code}');
        }
      }
      print("Error: ${e.code}");
    }
    //  _auth
    //   .signInWithEmailAndPassword(
    //     email: emailController.text,
    //     password: passwordController.text,
    //   )
    //   .then((userCredential) => {}, onError: (e) => {

    //   });
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
          title: Text('Login Page'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign In',
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

                  const SizedBox(height: 25),

                  CustomButton(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        signUserIn(context);
                      }
                    },
                    text: 'Sign In',
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Not a member?',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Register now',
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
                    text: 'Log In with Google',
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
