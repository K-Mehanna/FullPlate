// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  PENDING,
  ACCEPTED,
  COMPLETED
}

extension OrderStatusExtension on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.PENDING:
        return 'PENDING';
      case OrderStatus.ACCEPTED:
        return 'ACCEPTED';
      case OrderStatus.COMPLETED:
        return 'COMPLETED';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status) {
      case 'PENDING':
        return OrderStatus.PENDING;
      case 'ACCEPTED':
        return OrderStatus.ACCEPTED;
      case 'COMPLETED':
        return OrderStatus.COMPLETED;
      default:
        throw ArgumentError('Invalid status string: $status');
    }
  }
}

enum OrderSize {
  SMALL,
  MEDIUM,
  LARGE
}

extension OrderSizeExtension on OrderSize {
  String get value {
    switch (this) {
      case OrderSize.SMALL:
        return 'S';
      case OrderSize.MEDIUM:
        return 'M';
      case OrderSize.LARGE:
        return 'L';
    }
  }

  static OrderSize fromString(String size) {
    switch (size) {
      case 'S':
        return OrderSize.SMALL;
      case 'M':
        return OrderSize.MEDIUM;
      case 'L':
        return OrderSize.LARGE;
      default:
        throw ArgumentError('Invalid size string: $size');
    }
  }
}

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

class OrderInfo {
  final String name;
  final int quantity;
  final OrderCategory category;
  final OrderSize size;

  final DateTime timeCreated;
  DateTime? timeAccepted;
  DateTime? timeCompleted;

  final String donorId;
  String? kitchenId;

  OrderStatus status;

  String orderId;

  OrderInfo(
      {required this.name,
      required this.quantity,
      required this.category,
      required this.size,
      required this.timeCreated,
      this.timeAccepted,
      this.timeCompleted,
      required this.donorId,
      this.kitchenId,
      required this.status,
      this.orderId = "unset"
      });

  factory OrderInfo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;

    print(data);

    final order = OrderInfo(
      name: data['title'],
      quantity: data['quantity'],
      category: OrderCategoryExtension.fromCode(data['category']),
      size: OrderSizeExtension.fromString(data['size']),
      timeCreated: (data['timeCreated'] as Timestamp).toDate(),
      timeAccepted: (data['timeAccepted'] as Timestamp?)?.toDate(),
      timeCompleted: (data['timeCompleted'] as Timestamp?)?.toDate(),
      donorId: data['donorId'],
      kitchenId: data['kitchenId'],
      status: OrderStatusExtension.fromString(data['status']),
      orderId: data['offerId']
    );

    print(order);

    return order;
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": name,
      "quantity": quantity,
      "category": category.code,
      "size": size.value,
      "timeCreated": Timestamp.fromDate(timeCreated),
      if (timeAccepted != null)
        "timeAccepted": Timestamp.fromDate(timeAccepted!),
      if (timeCompleted != null)
        "timeCompleted": Timestamp.fromDate(timeCompleted!),
      "donorId": donorId,
      if (timeAccepted != null) "kitchenId": kitchenId,
      "status": status.value,
      "offerId": orderId
    };
  }
}
