import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KitchenInfo {
  final String name;
  final LatLng location;
  final String address;

  KitchenInfo({
    required this.name,
    required this.location,
    required this.address,
  });

  factory KitchenInfo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    final GeoPoint geoPoint = data['location'];

    return KitchenInfo(
      name: data['name'],
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      address: data['address'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "location": GeoPoint(location.latitude, location.longitude),
      "address": address,
    };
  }
}