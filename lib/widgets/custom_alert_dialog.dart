import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget adaptiveAction({
  required BuildContext context,
  required VoidCallback onPressed,
  required Widget child}) {
  final ThemeData theme = Theme.of(context);
  switch (theme.platform) {
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return TextButton(onPressed: onPressed, child: child);
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return CupertinoDialogAction(onPressed: onPressed, child: child);
  }
}

void CustomAlertDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog.adaptive(
        title: Text(message),
        actions: [
          adaptiveAction(
            context: context,
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}