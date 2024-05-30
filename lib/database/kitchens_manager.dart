import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cibu/models/kitchen_info.dart';
import 'dart:async';

class KitchensManager {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<KitchenInfo> getKitchen(String kitchenId) {
    final completer = Completer<KitchenInfo>();

    final kitchensRef = _db.collection("kitchens");

    kitchensRef.doc(kitchenId).get().then((querySnapshot) {
      KitchenInfo donor = KitchenInfo.fromFirestore(querySnapshot, null);
      completer.complete(donor);
    }, onError: (e) => print("kitchensManager\n - getKitchen: $e"));

    return completer.future;
  }

  void getKitchenCompletion(String kitchenId, void Function(KitchenInfo) callback) {
    final kitchensRef = _db.collection("kitchens");

    kitchensRef.doc(kitchenId).get().then((querySnapshot) {
      KitchenInfo donor = KitchenInfo.fromFirestore(querySnapshot, null);
      callback(donor);
    }, onError: (e) => print("kitchensManager\n - getKitchen: $e"));
  }
}