import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function()? onTap;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.validator,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: hintText,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        fillColor: Colors.grey.shade200,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500])
      ),
    );
  }
}