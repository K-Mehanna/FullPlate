import 'package:cibu/enums/user_type.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class CustomSingleChoice extends StatefulWidget {
  CustomSingleChoice({super.key});
  
  UserType userType = UserType.DONOR;

  @override
  State<CustomSingleChoice> createState() => _CustomSingleChoiceState();
}

class _CustomSingleChoiceState extends State<CustomSingleChoice> {

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<UserType>(
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
      selected: <UserType>{widget.userType},
      onSelectionChanged: (Set<UserType> newSelection) {
        setState(() {
          widget.userType = newSelection.first;
        });
      },
    );
  }
}