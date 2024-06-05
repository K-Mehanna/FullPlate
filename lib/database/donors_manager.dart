import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cibu/models/donor_info.dart';
import 'dart:async';

class DonorsManager {
    final FirebaseFirestore _db = FirebaseFirestore.instance;


    Future<DonorInfo> getDonor(String donorId) {
      final completer = Completer<DonorInfo>();

      final donorsRef = _db.collection("donors");

      donorsRef.doc(donorId).get().then((querySnapshot) {
        DonorInfo donor = DonorInfo.fromFirestore(querySnapshot, null, querySnapshot.id);
        completer.complete(donor);
      }, onError: (e) => print("DonorsManager\n - getDonor: $e"));

      return completer.future;
    }

    void getDonorsCompletion(void Function(List<DonorInfo>) callback) {
      final donorsRef = _db.collection("donors");

      donorsRef.get().then((querySnapshot) {
        List<DonorInfo> donors = [];

        for (var docSnapshot in querySnapshot.docs) {
          DonorInfo donor = DonorInfo.fromFirestore(docSnapshot, null, docSnapshot.id);
          donors.add(donor);
        }
        
        callback(donors);
      }, onError: (e) => print("DonorsManager\n - getDonors: $e"));
    } 

    void getDonorCompletion(String donorId, void Function(DonorInfo) callback) {
      final donorsRef = _db.collection("donors");

      donorsRef.doc(donorId).get().then((querySnapshot) {
        DonorInfo donor = DonorInfo.fromFirestore(querySnapshot, null, querySnapshot.id);
        callback(donor);
      }, onError: (e) => print("DonorsManager\n - getDonor: $e"));
    }

    void addDonor(DonorInfo donorInfo) {
      _db
        .collection("donors")
        .doc(donorInfo.donorId)
        .set(donorInfo.toFirestore())
        .then((a) {}, onError: (e) => print("Error: in addDonor"));
    }
}