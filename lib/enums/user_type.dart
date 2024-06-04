enum UserType {
  DONOR,
  KITCHEN,
}

extension UserTypeExtension on UserType {
  String get value {
    switch (this) {
      case UserType.DONOR:
        return 'Donor';
      case UserType.KITCHEN:
        return 'Kitchen';
    }
  }

  static UserType fromString(String type) {
    switch (type) {
      case 'Donor':
        return UserType.DONOR;
      case 'Kitchen':
        return UserType.KITCHEN;
      default:
        throw ArgumentError('Invalid user type string: $type');
    }
  }
}