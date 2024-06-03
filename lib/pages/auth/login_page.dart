// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cibu/widgets/custom_text_field.dart';
// import 'package:cibu/widgets/custom_button.dart';

// class LoginPage extends StatefulWidget {
//   LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   // text editing controllers
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   // sign user in method
//   void signUserIn() async {
//     // show loading circle
//     showDialog(
//       context: context,
//       builder: (context) {
//         return const Center(
//           child: CircularProgressIndicator(),
//         );
//       },
//     );

//     // try sign in
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailController.text,
//         password: passwordController.text,
//       );
//       // pop the loading circle
//       Navigator.pop(context);
//     } on FirebaseAuthException catch (e) {
//       // pop the loading circle
//       Navigator.pop(context);
//       // WRONG EMAIL
//       if (e.code == 'user-not-found' || e.code == 'wrong-password') {
//         // show error to user
//         invalidLoginMessage();
//       }
//     }
//   }

//   // wrong email message popup
//   void invalidLoginMessage() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return const AlertDialog(
//           backgroundColor: Colors.deepPurple,
//           title: Center(
//             child: Text(
//               'Incorrect Login',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         );
//       },
//     );
//   }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // email textfield
//             CustomTextField(
//               controller: emailController,
//               hintText: 'Email',
//               obscureText: false,
//             ),

//             const SizedBox(height: 10),

//             // password textfield
//             CustomTextField(
//               controller: passwordController,
//               hintText: 'Password',
//               obscureText: true,
//             ),

//             const SizedBox(height: 25),

//             // sign in button
//             CustomButton(
//               onTap: signUserIn,
//               text: 'Sign In',
//             ),

//             const SizedBox(height: 50),

//             // not a member? register now
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Not a member?',
//                   style: TextStyle(color: Colors.grey[700]),
//                 ),
//                 const SizedBox(width: 4),
//                 const Text(
//                   'Register now',
//                   style: TextStyle(
//                     color: Colors.blue,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }