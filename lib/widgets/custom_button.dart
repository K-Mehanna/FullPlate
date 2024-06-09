import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function()? onTap;
  final String text;

  const CustomButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16.0),
          backgroundColor: theme.colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          text,
          style: theme.textTheme.titleLarge!.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
      ),
    );
    
    // GestureDetector(
    //   onTap: onTap,
    //   child: Container(
    //     padding: const EdgeInsets.all(20),
    //     decoration: BoxDecoration(
    //       color: theme.colorScheme.secondary,
    //       borderRadius: BorderRadius.circular(8),
    //     ),
    //     child: Center(
    //       child: Text(
    //         text,
    //         style: theme.textTheme.titleLarge!.copyWith(
    //           color: theme.colorScheme.onSecondary,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}