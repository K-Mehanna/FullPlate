// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class KitchenSignupPage extends StatefulWidget {
//   @override
//   _KitchenSignupPageState createState() => _KitchenSignupPageState();
// }

// class _KitchenSignupPageState extends State<KitchenSignupPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Kitchen Signup'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(labelText: 'Email'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(labelText: 'Password'),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your password';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16.0),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState.validate()) {
//                     _signup();
//                   }
//                 },
//                 child: Text('Signup'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _signup() async {
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: _emailController.text,
//         password: _passwordController.text,
//       );
//       // TODO: Handle successful signup
//     } catch (e) {
//       // TODO: Handle signup error
//     }
//   }
// }