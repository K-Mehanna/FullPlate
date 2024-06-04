// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


enum OrderCategory {
  FRUIT_VEG,
  BREAD,
  READY_MEALS,
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
      default:
        throw ArgumentError('Invalid category code: $code');
    }
  }
}

class OfferInfo {
  final String name;
  int quantity;
  int selectedQuantity = 0;
  final OrderCategory category;
  String offerId;

  OfferInfo(
      {required this.name,
      required this.quantity,
      required this.category,
      this.offerId = "unassigned"
      });

  factory OfferInfo.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      String offerId) {
    final data = snapshot.data()!;

    final order = OfferInfo(
      name: data['title'],
      quantity: data['quantity'],
      category: OrderCategoryExtension.fromCode(data['category']),
      offerId: offerId
    );

    return order;
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": name,
      "quantity": quantity,
      "category": category.code,
      "offerId": offerId
    };
  }
}