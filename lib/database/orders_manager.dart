import 'package:cibu/models/offer_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cibu/models/job_info.dart';

class OrdersManager {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void addOpenOffer(String donorId, OfferInfo offer) {
    final baseDocumentRef = _db.collection("donors").doc(donorId);
    const nestedOffersPath = "openOffers";

    _addOffer(baseDocumentRef, nestedOffersPath, offer);
  }

  void acceptOpenOffer(String donorId, String kitchenId,
      List<OfferInfo> openOffers, List<int> selectedQuantity, void Function() callback) {
    final openOffersRef =
        _db.collection("donors").doc(donorId).collection("openOffers");

    int offerQuantity = selectedQuantity.reduce((a, b) => a + b);

    final existingJobQuery = _db
        .collection("jobs")
        .where("donorId", isEqualTo: donorId)
        .where("kitchenId", isEqualTo: kitchenId)
        .where("status", isEqualTo: OrderStatus.ACCEPTED.value);

    existingJobQuery.get().then((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        // make new job
        JobInfo job = JobInfo(
            timeAccepted: DateTime.now(),
            donorId: donorId,
            kitchenId: kitchenId,
            status: OrderStatus.ACCEPTED,
            quantity: offerQuantity);

        _db.collection("jobs").add(job.toFirestore()).then((docSnapshot) {
          final baseDocumentRef = _db.collection("jobs").doc(docSnapshot.id);

          _conductTransaction(
              openOffers, openOffersRef, selectedQuantity, baseDocumentRef, callback);
        });
      } else {
        JobInfo previousJob =
            JobInfo.fromFirestore(querySnapshot.docs[0], null);

        _db.collection("jobs").doc(previousJob.jobId).update(
            {"quantity": previousJob.quantity + offerQuantity}).then((other) {
          final baseDocumentRef = _db.collection("jobs").doc(previousJob.jobId);

          _conductTransaction(
              openOffers, openOffersRef, selectedQuantity, baseDocumentRef, callback);
        });
      }
    });
  }

  void _conductTransaction(
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
      // READ

      List<int> previousQuantity = [];

      for (OfferInfo offer in openOffers) {
        final newOfferRef =
            baseJobRef.collection("constituentOffers").doc(offer.category.code);

        DocumentSnapshot snapshot = await transaction.get(newOfferRef);

        if (snapshot.exists) {
          int q = snapshot.get("quantity");
          previousQuantity.add(q);
        } else {
          previousQuantity.add(0);
        }
      }

      // WRITE

      // old offers decrement quantity (delete / update)
      for (OfferInfo offer in openOffers) {
        final offerRef = openOffersRef.doc(offer.category.code);

        if (offer.quantity > 0) {
          transaction.update(offerRef, {"quantity": offer.quantity});
        } else {
          transaction.delete(offerRef);
        }
      }

      // new offers increment quantity (add / update)
      for (int i = 0; i < openOffers.length; i++) {
        OfferInfo offer = openOffers[i];

        final newOfferRef =
            baseJobRef.collection("constituentOffers").doc(offer.category.code);

        transaction.set(newOfferRef, {
          "quantity": previousQuantity[i] + selectedQuantity[i],
          "category": offer.category.code
        });
      }
    }).then((e) {
      callback();
    }, onError: (e) => print("transaction failure: $e"));
  }

  void _addOffer(DocumentReference<Map<String, dynamic>> baseDocumentRef,
      String nestedOffersPath, OfferInfo offer) {
    final offerRef =
        baseDocumentRef.collection(nestedOffersPath).doc(offer.category.code);

    offerRef.get().then((docSnapshot) {
      if (docSnapshot.exists) {
        final int previousQuantity = docSnapshot.data()!["quantity"];

        offerRef.update({"quantity": previousQuantity + offer.quantity});
      } else {
        offerRef.set(offer.toFirestore());
      }
    });

    baseDocumentRef.get().then((docSnapshot) {
      final previousQuantity = docSnapshot.data()!["quantity"];

      baseDocumentRef.update({
        "quantity": previousQuantity + offer.quantity
      }).then((a) {},
          onError: (e) => print(
              "OrdersManager\n - addOpenOffer\n - update donor quantity $e"));
    });
  }

  void getOpenOffersCompletion(
      String donorId, void Function(List<OfferInfo>) callback) {
    final query =
        _db.collection("donors").doc(donorId).collection("openOffers");

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
    final query =
        _db.collection("donors").doc(donorId).collection("openOffers");

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
}
