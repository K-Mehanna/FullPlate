// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum OrderCategory {
  FRUIT_VEG,
  BREAD,
  READY_MEALS,
  MISCELLANEOUS,
}

extension OrderCategoryExtension on OrderCategory {
  String get value {
    switch (this) {
      case OrderCategory.FRUIT_VEG:
        return "Fruits & Veg";
      case OrderCategory.BREAD:
        return "Bread";
      case OrderCategory.READY_MEALS:
        return "Ready Meals";
      case OrderCategory.MISCELLANEOUS:
        return "Miscellaneous";
    }
  }

  Icon get icon {
    switch (this) {
      case OrderCategory.BREAD:
        return Icon(Icons.breakfast_dining_sharp);
      case OrderCategory.FRUIT_VEG:
        return Icon(Icons.apple);
      case OrderCategory.READY_MEALS:
        return Icon(Icons.set_meal_outlined);
      case OrderCategory.MISCELLANEOUS:
        return Icon(Icons.question_mark);
    }
  }

  String get code {
    switch (this) {
      case OrderCategory.FRUIT_VEG:
        return "FRV";
      case OrderCategory.BREAD:
        return "BRD";
      case OrderCategory.READY_MEALS:
        return "MRE";
      case OrderCategory.MISCELLANEOUS:
        return "MIS";
    }
  }

  static OrderCategory fromCode(String code) {
    switch (code) {
      case "FRV":
        return OrderCategory.FRUIT_VEG;
      case "BRD":
        return OrderCategory.BREAD;
      case "MRE":
        return OrderCategory.READY_MEALS;
      case "MIS":
        return OrderCategory.MISCELLANEOUS;
      default:
        throw ArgumentError('Invalid category code: $code');
    }
  }
}

class OfferInfo {
  String offerId;
  DateTime expiryDate;
  int quantity;
  int selectedQuantity = 0;
  final OrderCategory category;

  OfferInfo({
    required this.offerId,
    required this.expiryDate,
    required this.quantity,
    required this.category,
  });

  factory OfferInfo.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data()!;

    final order = OfferInfo(
      offerId: snapshot.id,
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      quantity: data['quantity'],
      category: OrderCategoryExtension.fromCode(data['category']),
    );

    return order;
  }

  String getExpiryDescription() {
    int days = expiryDate.difference(DateTime.now().subtract(Duration(days: 1))).inDays;

    return "$days day${days > 1 ? "s" : " "}";
  }

  Map<String, dynamic> toFirestore() {
    return {
      "quantity": quantity, 
      "expiryDate": Timestamp.fromDate(expiryDate),
      "category": category.code
    };
  }
}
