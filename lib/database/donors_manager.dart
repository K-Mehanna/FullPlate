import 'package:cibu/models/offer_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cibu/models/donor_info.dart';
import 'dart:async';

class DonorsManager {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  StreamSubscription? filteredOfferDonorsListener;

  Future<DonorInfo> getDonor(String donorId) {
    final completer = Completer<DonorInfo>();

    final donorsRef = _db.collection("donors");

    donorsRef.doc(donorId).get().then((querySnapshot) {
      DonorInfo donor = DonorInfo.fromFirestore(querySnapshot, null);
      completer.complete(donor);
    }, onError: (e) => print("DonorsManager\n - getDonor: $e"));

    return completer.future;
  }

  // void getOfferDonorsCompletion(void Function(List<DonorInfo>) callback) {
  //   final donorsRef =
  //       _db.collection("donors").where("quantity", isGreaterThan: 0);

  //   donorsRef.get().then((querySnapshot) {
  //     List<DonorInfo> donors = [];

  //     for (var docSnapshot in querySnapshot.docs) {
  //       DonorInfo donor = DonorInfo.fromFirestore(docSnapshot, null);

  //       assert(donor.quantity > 0);
  //       donors.add(donor);
  //     }

  //     callback(donors);
  //   }, onError: (e) => print("DonorsManager\n - getDonors: $e"));
  // }

  void _cancelFilteredOfferDonorsListener() {
    assert(filteredOfferDonorsListener != null);
    
    filteredOfferDonorsListener!.cancel();
    filteredOfferDonorsListener = null;
  }

  void setFilteredOfferDonorsListener(
      void Function(List<DonorInfo>) callback, List<OrderCategory> categories) {
    if (filteredOfferDonorsListener != null) {
      _cancelFilteredOfferDonorsListener();
    }

    Query<Map<String, dynamic>> donorsRef;
    if (categories.isEmpty) {
      callback([]);
      return;
    } else {
      donorsRef = _db
        .collection("donors")
        .where("quantity", isGreaterThan: 0)
        .where("offerSummary",
            arrayContainsAny: categories.map((e) => e.code).toList());
    }

    filteredOfferDonorsListener = donorsRef.snapshots().listen((querySnapshot) {
      List<DonorInfo> donors = [];

      for (var docSnapshot in querySnapshot.docs) {
        DonorInfo donor = DonorInfo.fromFirestore(docSnapshot, null);

        assert(donor.quantity > 0);
        donors.add(donor);
      }

      callback(donors);
    }, onError: (e) => print("DonorsManager\n - getDonors: $e"));
  }

  void getDonorCompletion(String donorId, void Function(DonorInfo) callback) {
    final donorsRef = _db.collection("donors");

    donorsRef.doc(donorId).get().then((querySnapshot) {
      DonorInfo donor = DonorInfo.fromFirestore(querySnapshot, null);
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

  void deleteDonorCompletion(DonorInfo donor, void Function(bool) onCompletion) {
    if (donor.quantity > 0) {
      onCompletion(false);
      return;
    }

    final openOffersRef = _db
      .collection("donors")
      .doc(donor.donorId)
      .collection("openOffers");
    
    openOffersRef
      .get()
      .then((docSnapshots) {
        bool outcome = true;
        
        for (var docSnapshot in docSnapshots.docs) {
          outcome &= docSnapshot.exists;
          openOffersRef
            .doc(docSnapshot.id)
            .delete();
        }

        onCompletion(outcome);
      }, onError: (e) => print("DonorsManager\n - deleteDonor $e"));
  }
}
