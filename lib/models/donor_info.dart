import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonorInfo {
  final String name;
  final LatLng location;
  final String address;
  final String donorId;

  DonorInfo({
    required this.name,
    required this.location,
    required this.address,
    required this.donorId
  });

  factory DonorInfo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
    String donorId
  ) {
    final data = snapshot.data()!;
    final GeoPoint geoPoint = data['location'];

    return DonorInfo(
      name: data['name'],
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      address: data['address'],
      donorId: donorId
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