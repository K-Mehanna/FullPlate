

import 'package:cibu/enums/user_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfo {
  final UserType userType;
  final bool completedProfile;

  UserInfo({
    required this.userType,
    required this.completedProfile
  });

  factory UserInfo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot
  ) {
    final data = snapshot.data()!;

    return UserInfo(
      userType: UserTypeExtension.fromString(data['userType']),
      completedProfile: data['completedProfile']
    );
  }
}