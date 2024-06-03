import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cibu/models/order_info.dart';
import 'dart:async';

class OrdersManager {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void addPendingOrder(OrderInfo order, void Function()? callback) {
    assert(order.status == OrderStatus.PENDING);

    final offersRef = _db.collection("offers");

    final offerRef = offersRef.add(order.toFirestore());

    offerRef.then((offerSnapshot) {
      final offerId = offerSnapshot.id;

      offerSnapshot.update({"offerId": offerId}).then((updateSnap) {
        if (callback != null) callback();
      },
          onError: (e) =>
              print("OrdersManager\n - addPendingOrder - update offerId: $e"));
    },
        onError: (e) =>
            print("OrdersManager\n - addPendingOrder - add offer: $e"));
  }

  void acceptOrder(
      OrderInfo order, String kitchenId, void Function()? callback) {
    assert(order.status == OrderStatus.PENDING);

    _db.collection("offers").doc(order.orderId).update({
      "status": OrderStatus.ACCEPTED.value,
      "timeAccepted": Timestamp.fromDate(DateTime.now()),
      "kitchenId": kitchenId,
    }).then((orderSnapshot) {
      if (callback != null) callback();
    }, onError: (e) => print("OrdersManager\n - acceptOrder"));
  }

  Query<Map<String, dynamic>> _buildOrdersQuery(OrderStatus status,
      bool shouldLimit, String? donorId, String? kitchenId) {
    final offersRef = _db.collection("offers");

    var query = offersRef.where("status", isEqualTo: status.value);

    if (donorId != null) {
      query = query.where("donorId", isEqualTo: donorId);
    }
    if (kitchenId != null) {
      query = query.where("kitchenId", isEqualTo: kitchenId);
    }
    if (shouldLimit) {
      query.limit(10);
    }

    return query;
  }

  Future<List<OrderInfo>> getOrders(OrderStatus status, bool shouldLimit,
      String? donorId, String? kitchenId) {
    var query = _buildOrdersQuery(status, shouldLimit, donorId, kitchenId);

    return _fetchQuery(query.orderBy("timeCreated", descending: true));
  }

  void getOrdersCompletion(
      OrderStatus status,
      bool shouldLimit,
      String? donorId,
      String? kitchenId,
      void Function(List<OrderInfo>) callback) {
    var query = _buildOrdersQuery(status, shouldLimit, donorId, kitchenId);

    _fetchQueryCallback(
        query.orderBy("timeCreated", descending: true), callback);
  }

  void setOrderListener(
      OrderStatus status,
      bool shouldLimit,
      String? donorId,
      String? kitchenId,
      void Function(List<OrderInfo>) callback) {
    var query = _buildOrdersQuery(status, shouldLimit, donorId, kitchenId);

    query.snapshots().listen((querySnapshot) {
      List<OrderInfo> orders = [];

      for (var docSnapshot in querySnapshot.docs) {
        orders.add(OrderInfo.fromFirestore(docSnapshot, null));
      }

      callback(orders);
    });
  }

  Future<List<OrderInfo>> _fetchQuery(Query<Map<String, dynamic>> query) {
    final completer = Completer<List<OrderInfo>>();

    query.get().then((querySnapshot) {
      List<OrderInfo> orders = [];

      for (var docSnapshot in querySnapshot.docs) {
        orders.add(OrderInfo.fromFirestore(docSnapshot, null));
      }

      completer.complete(orders);
    }, onError: (e) => print("OrdersManager\n - _fetchQuery: $e"));

    return completer.future;
  }

  void _fetchQueryCallback(Query<Map<String, dynamic>> query,
      void Function(List<OrderInfo>) callback) {
    query.get().then((querySnapshot) {
      List<OrderInfo> orders = [];

      for (var docSnapshot in querySnapshot.docs) {
        orders.add(OrderInfo.fromFirestore(docSnapshot, null));
      }

      callback(orders);
    }, onError: (e) => print("OrdersManager\n - _fetchQuery: $e"));
  }
}
