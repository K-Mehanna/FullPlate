import 'package:cibu/database/kitchens_manager.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/models/offer_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cibu/models/job_info.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersManager {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void addOpenOffer(
      String donorId, OfferInfo offer, void Function() onCompletion) {
    addOpenOffers(donorId, [offer], onCompletion);
  }

  void removeOpenOffer(
      String donorId, OfferInfo offer, void Function() onCompletion) {
    final donorRef = _db.collection("donors").doc(donorId);
    final offersRef = donorRef.collection("openOffers");
    final offerRef = offersRef.doc(offer.offerId);

    offerRef.delete().then((res) {
      donorRef.get().then((docSnapshot) {
        DonorInfo donor = DonorInfo.fromFirestore(docSnapshot, null);

        donorRef.update({"quantity": donor.quantity - offer.quantity}).then(
            (e) {
          offersRef
              .where("category", isEqualTo: offer.category.code)
              .count()
              .get()
              .then((res) {
            if (res.count == 0) {
              donorRef.update({
                "offerSummary": FieldValue.arrayRemove([offer.category.code])
              }).then((res) {
                onCompletion();
              }, onError: (e) => print("iehfoiewhf :(((())))"));
            }
          });
        },
            onError: (e) =>
                print("OrdersManager\n - removeOpenOffer: update donor $e"));
      });
      onCompletion();
    }, onError: (e) => print("OrdersManager\n - removeOpenOffer: $e"));
  }

  void addOpenOffers(
      String donorId, List<OfferInfo> offers, void Function() onCompletion) {
    final baseDocumentRef = _db.collection("donors").doc(donorId);
    const nestedOffersPath = "openOffers";

    print("potato");

    _addOffers(baseDocumentRef, nestedOffersPath, offers, onCompletion);
  }

  void _addOffers(
      DocumentReference<Map<String, dynamic>> baseDocumentRef,
      String nestedOffersPath,
      List<OfferInfo> offers,
      void Function() onCompletion) {
    List<String> orders = offers
        .map((offer) => offer.category)
        .toSet()
        .toList()
        .map((category) => category.code)
        .toList();

    print('Reached here');
    _db.runTransaction((transaction) async {
      final baseDoc = await transaction.get(baseDocumentRef);
      int previousQuantity = baseDoc.get("quantity");
      List<int> previousOfferQuantities = [];

      for (var offer in offers) {
        if (offer.offerId == "unassigned") {
          previousOfferQuantities.add(0);
        } else {
          final offerDoc = await baseDocumentRef
              .collection(nestedOffersPath)
              .doc(offer.offerId)
              .get();

          if (offerDoc.exists) {
            previousOfferQuantities.add(offerDoc.data()!["quantity"]);
          } else {
            previousOfferQuantities.add(0);
          }
        }
      }

      transaction.update(
          baseDocumentRef, {"offerSummary": FieldValue.arrayUnion(orders)});

      for (int i = 0; i < offers.length; i++) {
        final offer = offers[i];

        final offerRef = baseDocumentRef
            .collection(nestedOffersPath)
            .doc(offer.offerId == "unassigned" ? null : offer.offerId);

        var data = offer.toFirestore();
        data["quantity"] += previousOfferQuantities[i];

        transaction.set(offerRef, data);
      }

      transaction.update(baseDocumentRef, {
        "quantity": previousQuantity +
            offers.map((a) => a.quantity).reduce((a, b) => a + b)
      });
    }).then((e) {
      onCompletion();
    }, onError: (e) => print("OrdersManager\n - _addOrders: $e"));
  }

  void cancelJob(JobInfo job, void Function() onCompletion) {
    assert(job.status == OrderStatus.ACCEPTED);

    _db
        .collection("jobs")
        .doc(job.jobId)
        .update({"status": OrderStatus.CANCELLED.value}).then((empty) {
      KitchensManager().markJobCancelledInKitchen(job);

      getConstituentOffersCompletion(job.jobId, (constituentOffers) {
        final baseDocumentRef = _db.collection("donors").doc(job.donorId);

        const nestedOffersPath = "openOffers";

        _addOffers(
            baseDocumentRef, nestedOffersPath, constituentOffers, onCompletion);
      });
    }, onError: (e) => print("OrdersManager\n - cancelJob: $e"));
  }

  void setJobCompleted(JobInfo job, void Function() onCompletion) {
    assert(job.status == OrderStatus.ACCEPTED);

    _db.collection("jobs").doc(job.jobId).update({
      "status": OrderStatus.COMPLETED.value,
      "timeCompleted": Timestamp.fromDate(DateTime.now())
    }).then((empty) {
      onCompletion();
    }, onError: (e) => print("OrdersManager\n - setJobCompleted: $e"));
  }

  void acceptOpenOffer(
      String donorId,
      String kitchenId,
      List<OfferInfo> openOffers,
      List<int> selectedQuantity,
      void Function() callback) {
    final openOffersRef =
        _db.collection("donors").doc(donorId).collection("openOffers");

    int offerQuantity = selectedQuantity.reduce((a, b) => a + b);

    final existingJobQuery = _db
        .collection("jobs")
        .where("donorId", isEqualTo: donorId)
        .where("kitchenId", isEqualTo: kitchenId)
        .where("status", isEqualTo: OrderStatus.ACCEPTED.value);

    Set<OrderCategory> offerSummary = {};

    for (int i = 0; i < openOffers.length; i++) {
      if (selectedQuantity[i] > 0) {
        offerSummary.add(openOffers[i].category);
      }
    }

    existingJobQuery.get().then((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        // make new job
        JobInfo job = JobInfo(
            timeAccepted: DateTime.now(),
            donorId: donorId,
            kitchenId: kitchenId,
            status: OrderStatus.ACCEPTED,
            offerSummary: offerSummary.toList(),
            quantity: offerQuantity);

        _db.collection("jobs").add(job.toFirestore()).then((docSnapshot) {
          final baseDocumentRef = _db.collection("jobs").doc(docSnapshot.id);

          _conductTransaction(donorId, openOffers, openOffersRef,
              selectedQuantity, baseDocumentRef, callback);
        });
      } else {
        JobInfo previousJob =
            JobInfo.fromFirestore(querySnapshot.docs[0], null);

        _db.collection("jobs").doc(previousJob.jobId).update({
          "quantity": previousJob.quantity + offerQuantity,
          "offerSummary": FieldValue.arrayUnion(
              offerSummary.toList().map((category) => category.code).toList())
        }).then((other) {
          final baseDocumentRef = _db.collection("jobs").doc(previousJob.jobId);

          _conductTransaction(donorId, openOffers, openOffersRef,
              selectedQuantity, baseDocumentRef, callback);
        });
      }
    });
  }

  void _conductTransaction(
      String donorId,
      List<OfferInfo> openOffers,
      CollectionReference<Map<String, dynamic>> openOffersRef,
      List<int> selectedQuantity,
      DocumentReference<Map<String, dynamic>> baseJobRef,
      void Function() callback) {
    for (int i = 0; i < selectedQuantity.length; i++) {
      openOffers[i].quantity -= selectedQuantity[i];
      assert(openOffers[i].quantity >= 0);
    }

    _db.runTransaction((transaction) async {
      final donorRef = _db.collection("donors").doc(donorId);

      // WRITE

      for (var category in OrderCategory.values) {
        List<OfferInfo> reducedOffers =
            openOffers.where((offer) => offer.category == category).toList();
        if (reducedOffers.isEmpty) continue;

        int newQuantity = reducedOffers
            .map((offer) => offer.quantity)
            .reduce((a, b) => a + b);

        if (newQuantity == 0) {
          transaction.update(donorRef, {
            "offerSummary": FieldValue.arrayRemove([category.code])
          });
        }
      }

      transaction.update(donorRef, {
        "quantity": openOffers.map((a) => a.quantity).reduce((a, b) => a + b)
      });

      // old offers decrement quantity (delete / update)
      for (OfferInfo offer in openOffers) {
        final offerRef = openOffersRef.doc(offer.offerId);

        if (offer.quantity > 0) {
          transaction.update(offerRef, {"quantity": offer.quantity});
        } else {
          transaction.delete(offerRef);
        }
      }

      // new offers increment quantity (add / update)
      for (int i = 0; i < openOffers.length; i++) {
        if (selectedQuantity[i] == 0) continue;

        OfferInfo offer = openOffers[i];

        assert(offer.offerId != "unassigned");
        final newOfferRef =
            baseJobRef.collection("constituentOffers").doc(offer.offerId);

        Map<String, dynamic> offerData = offer.toFirestore();
        offerData["quantity"] = selectedQuantity[i];

        transaction.set(newOfferRef, offerData);
      }
    }).then((e) {
      callback();
    }, onError: (e) => print("transaction failure: $e"));
  }

  void getOpenOffersCompletion(
      String donorId, void Function(List<OfferInfo>) callback) {
    final query = _db
        .collection("donors")
        .doc(donorId)
        .collection("openOffers")
        .where("expiryDate", isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy("expiryDate");

    _fetchOfferCallback(query, callback);
  }

  void _fetchOfferCallback(Query<Map<String, dynamic>> query,
      void Function(List<OfferInfo>) callback) {
    query.get().then((querySnapshot) {
      List<OfferInfo> offers = [];

      for (var docSnapshot in querySnapshot.docs) {
        offers.add(OfferInfo.fromFirestore(docSnapshot, null));
      }

      callback(offers);
    }, onError: (e) => print("OrdersManager\n - _fetchQueryCallback: $e"));
  }

  Query<Map<String, dynamic>> _buildJobsQuery(
      OrderStatus status, String? donorId, String? kitchenId) {
    var query = _db.collection("jobs").where("status", isEqualTo: status.value);

    if (donorId != null) {
      query = query.where("donorId", isEqualTo: donorId);
    }
    if (kitchenId != null) {
      query = query.where("kitchenId", isEqualTo: kitchenId);
    }

    return query;
  }

  void getConstituentOffersCompletion(
      String jobId, void Function(List<OfferInfo>) callback) {
    final constituentOffersRef =
        _db.collection("jobs").doc(jobId).collection("constituentOffers");

    constituentOffersRef.get().then((querySnapshot) {
      List<OfferInfo> offers = [];

      for (var docSnapshot in querySnapshot.docs) {
        OfferInfo offer = OfferInfo.fromFirestore(docSnapshot, null);
        offers.add(offer);
      }

      callback(offers);
    },
        onError: (e) =>
            print("OrdersManager\n - getConstituentOffersCompletion: $e"));
  }

  void getJobsCompletion(OrderStatus status, String? donorId, String? kitchenId,
      void Function(List<JobInfo>) callback) {
    var query = _buildJobsQuery(status, donorId, kitchenId);

    _fetchJobsCallback(
        query.orderBy("timeAccepted", descending: true), callback);
  }

  void _fetchJobsCallback(Query<Map<String, dynamic>> query,
      void Function(List<JobInfo>) callback) {
    query.get().then((querySnapshot) {
      List<JobInfo> offers = [];

      for (var docSnapshot in querySnapshot.docs) {
        offers.add(JobInfo.fromFirestore(docSnapshot, null));
      }

      callback(offers);
    }, onError: (e) => print("OrdersManager\n - _fetchQueryCallback: $e"));
  }

  void setOpenOffersListener(
      String donorId, void Function(List<OfferInfo>) callback) {
    final query = _db
        .collection("donors")
        .doc(donorId)
        .collection("openOffers")
        .where("expiryDate", isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy("expiryDate");

    query.snapshots().listen((querySnapshot) {
      List<OfferInfo> offers = [];

      for (var docSnapshot in querySnapshot.docs) {
        offers.add(OfferInfo.fromFirestore(docSnapshot, null));
      }

      callback(offers);
    });
  }

  void setJobsListener(OrderStatus status, String? donorId, String? kitchenId,
      void Function(List<JobInfo>) callback) {
    var query = _buildJobsQuery(status, donorId, kitchenId);

    query.snapshots().listen((querySnapshot) {
      List<JobInfo> jobs = [];

      for (var docSnapshot in querySnapshot.docs) {
        jobs.add(JobInfo.fromFirestore(docSnapshot, null));
      }

      callback(jobs);
    });
  }

  void setCompletedJobsListener(String? donorId, String? kitchenId,
      void Function(List<JobInfo>) callback) {
   
    var query = _buildJobsQuery(OrderStatus.COMPLETED, donorId, kitchenId);

    query.snapshots().listen((querySnapshot) {
      List<JobInfo> jobs = [];

      for (var docSnapshot in querySnapshot.docs) {
        jobs.add(JobInfo.fromFirestore(docSnapshot, null));
      }

      callback(jobs);
    });
  }
}
