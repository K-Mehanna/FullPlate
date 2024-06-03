import 'package:cibu/models/offer_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cibu/models/job_info.dart';
import 'dart:async';

class OrdersManager {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void addOpenOffer(String donorId, OfferInfo offer) {
    final openOffersRef = _db
      .collection("donors")
      .doc(donorId)
      .collection("openOffers");

    openOffersRef.add(offer.toFirestore())
      .then((a) {}, onError: (e) => print("\nOrdersManager\n - addOpenOffer"));
  }

  void acceptOpenOffer(String donorId, String kitchenId, List<OfferInfo> openOffers, List<int> selectedQuantity) {
    final openOffersRef = _db
      .collection("donors")
      .doc(donorId)
      .collection("openOffers");

    int i = 0;
    for (OfferInfo offer in openOffers) {
      final openOffer = openOffersRef.doc(offer.offerId);

      final newQuantity = offer.quantity - selectedQuantity[i];
      assert(newQuantity >= 0);

      Future<void> outcome;
      if (newQuantity > 0) {
        outcome = openOffer.update({
          "quantity": offer.quantity - selectedQuantity[0]
        });
      } else {
        outcome = openOffer.delete();
      }
      
      outcome.then((a) {
        print("success for ${offer.name} (${offer.quantity} left)");
      }, onError: (e) => print("\nOrdersManager\n - acceptOpenOffer\n - updating offer quantities"));
      
      offer.quantity = selectedQuantity[i];

      i++;
    }

    JobInfo job = JobInfo(
      timeAccepted: DateTime.now(), 
      donorId: donorId, 
      kitchenId: kitchenId, 
      status: OrderStatus.ACCEPTED,
      quantity: openOffers.map((offer) => offer.quantity).reduce((a, b) => a + b)
    );

    _db.collection("jobs").add(job.toFirestore())
    .then((a) {}, onError: (e) => print("\nOrdersManager\n - acceptOpenOffer\n - adding job"));
  }

  void getOpenOffersCompletion(
      String donorId,
      void Function(List<OfferInfo>) callback) {
    final query = _db
      .collection("donors")
      .doc(donorId)
      .collection("openOffers");

    _fetchOfferCallback(
        query.orderBy("timeCreated", descending: true), callback);
  }

  void _fetchOfferCallback(Query<Map<String, dynamic>> query,
      void Function(List<OfferInfo>) callback) {
    query.get().then((querySnapshot) {
      List<OfferInfo> offers = [];

      for (var docSnapshot in querySnapshot.docs) {
        offers.add(OfferInfo.fromFirestore(docSnapshot, null, docSnapshot.id));
      }

      callback(offers);
    }, onError: (e) => print("OrdersManager\n - _fetchQueryCallback: $e"));
  }

  Query<Map<String, dynamic>> _buildJobsQuery(OrderStatus status, String? donorId, String? kitchenId) {
    var query = _db
      .collection("jobs")
      .where("status", isEqualTo: status.value);

    if (donorId != null) {
      query = query.where("donorId", isEqualTo: donorId);
    }
    if (kitchenId != null) {
      query = query.where("kitchenId", isEqualTo: kitchenId);
    }

    return query;
  }

  void getJobsCompletion(OrderStatus status, String? donorId, String? kitchenId, void Function(List<JobInfo>) callback) {
    var query = _buildJobsQuery(status, donorId, kitchenId);

    _fetchJobsCallback(
      query.orderBy("timeAccepted", descending: true), callback);
  }

  void _fetchJobsCallback(Query<Map<String, dynamic>> query,
      void Function(List<JobInfo>) callback) {
    query.get().then((querySnapshot) {
      List<JobInfo> offers = [];

      for (var docSnapshot in querySnapshot.docs) {
        offers.add(JobInfo.fromFirestore(docSnapshot, null, docSnapshot.id));
      }

      callback(offers);
    }, onError: (e) => print("OrdersManager\n - _fetchQueryCallback: $e"));
  }

  void setOpenOffersListener(
      String donorId,
      void Function(List<OfferInfo>) callback) {
    final query = _db
      .collection("donors")
      .doc(donorId)
      .collection("openOffers");

    query.snapshots().listen((querySnapshot) {
      List<OfferInfo> offers = [];

      for (var docSnapshot in querySnapshot.docs) {
        offers.add(OfferInfo.fromFirestore(docSnapshot, null, docSnapshot.id));
      }

      callback(offers);
    });
  }

  void setJobsListener(OrderStatus status, String? donorId, String? kitchenId, void Function(List<JobInfo>) callback) {
    var query = _buildJobsQuery(status, donorId, kitchenId);

    query.snapshots().listen((querySnapshot) {
      List<JobInfo> jobs = [];

      for (var docSnapshot in querySnapshot.docs) {
        jobs.add(JobInfo.fromFirestore(docSnapshot, null, docSnapshot.id));
      }

      callback(jobs);
    });
  }
}
