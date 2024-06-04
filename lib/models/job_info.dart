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

class JobInfo {
  DateTime timeAccepted;
  DateTime? timeCompleted;

  final String donorId;
  final String kitchenId;

  final OrderStatus status;
  final int quantity;

  final String jobId;

  JobInfo(
      {required this.timeAccepted,
      this.timeCompleted,
      required this.donorId,
      required this.kitchenId,
      required this.status,
      required this.quantity,
      this.jobId = "unassigned"
      });

  factory JobInfo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options
  ) {
    final data = snapshot.data()!;

    final job = JobInfo(
      timeAccepted: (data['timeAccepted'] as Timestamp).toDate(),
      timeCompleted: (data['timeCompleted'] as Timestamp?)?.toDate(),
      donorId: data['donorId'],
      kitchenId: data['kitchenId'],
      status: OrderStatusExtension.fromString(data['status']),
      quantity: data['quantity'],
      jobId: snapshot.id
    );

    return job;
  }

  Map<String, dynamic> toFirestore() {
    return {
      "timeAccepted": Timestamp.fromDate(timeAccepted),
      if (timeCompleted != null)
        "timeCompleted": Timestamp.fromDate(timeCompleted!),
      "donorId": donorId,
      "kitchenId": kitchenId,
      "status": status.value,
      "quantity": quantity
    };
  }
}
