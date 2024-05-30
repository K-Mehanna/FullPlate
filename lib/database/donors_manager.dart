import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cibu/models/donor_info.dart';
import 'dart:async';

class DonorsManager {
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    Future<DonorInfo> getDonor(String donorId) {
      final completer = Completer<DonorInfo>();

      final donorsRef = _db.collection("donors");

      donorsRef.doc(donorId).get().then((querySnapshot) {
        DonorInfo donor = DonorInfo.fromFirestore(querySnapshot, null);
        completer.complete(donor);
      }, onError: (e) => print("DonorsManager\n - getDonor: $e"));

      return completer.future;
    }

    void getDonorCompletion(String donorId, void Function(DonorInfo) callback) {
      final donorsRef = _db.collection("donors");

      donorsRef.doc(donorId).get().then((querySnapshot) {
        DonorInfo donor = DonorInfo.fromFirestore(querySnapshot, null);
        callback(donor);
      }, onError: (e) => print("DonorsManager\n - getDonor: $e"));
    } 

    // Future<List<DonorInfo>> getDonors() { // idk if this works
    //   final completer = Completer<List<DonorInfo>>();

    //   final donorsRef = _db.collection("donors");

    //   donorsRef.get().then((querySnapshot) {
    //     List<DonorInfo> donorList = querySnapshot.docs
    //     .map((doc) => DonorInfo.fromFirestore(doc, null))
    //     .toList();
    //     completer.complete(donorList);
    //   }, onError: (e) => print("DonorsManager\n - getDonors: $e"));

    //   return completer.future;
    // }
}