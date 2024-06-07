import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 20.0),
          child: Divider(
            color: Colors.black,
          )),
      ),
      Text("OR"),
      Expanded(
        child: Container(
          margin: const EdgeInsets.only(left: 20.0),
          child: Divider(
            color: Colors.black,
          )),
      ),
    ]);
  }
}