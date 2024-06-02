import 'dart:async';

import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/order_info.dart';
import 'package:cibu/pages/kitchen/donor_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class KitchenMapPage extends StatefulWidget {
  KitchenMapPage({super.key});

  @override
  State<KitchenMapPage> createState() => _KitchenMapPageState();
}

class _KitchenMapPageState extends State<KitchenMapPage> {
  final OrdersManager ordersManager = OrdersManager();
  final DonorsManager donorsManager = DonorsManager();
  late GoogleMapController mapController;
  static LatLng currentPosition = LatLng(0.0, 0.0);
  late List<OrderInfo> orders = [];
  late Set<Marker> markers = {};

  void getCurrentLocation(void Function(Position) callback) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Future<Position> position =
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    position.then(callback, onError: (e) => print("An error occured fetching location:\n$e"));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    print("\nKitchenMapPageState\n - initState()\n");
    super.initState();
    ordersManager.getOrdersCompletion(
        OrderStatus.PENDING, false, null, null, createMarkers);
    getCurrentLocation((newLocation) {
      var newPosition = LatLng(newLocation.latitude, newLocation.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(newPosition));
      setState(() {
        print('previous: ${currentPosition.toString()}');
        currentPosition = newPosition;
        print('new: ${currentPosition.toString()}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available donors'),
        elevation: 2,
      ),
      body: GoogleMap(
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: currentPosition,
          zoom: 16.0,
        ),
        markers: markers,
      ),
    );
  }

  void createMarkers(List<OrderInfo> orders) {
    print("\nKitchenMapPageState\n - createMarkers()\n");
    setState(() {
      markers.clear();
    });

    for (var order in orders) {
      donorsManager.getDonorCompletion(order.donorId, (donor) {
        setState(() { markers.add(
          Marker(
            markerId: MarkerId(order.orderId),
            position: donor.location,
            infoWindow: InfoWindow(
              title: donor.name,
              snippet: donor.address,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DonorDetailPage(order: order),
                  ),
                );
              },
            ),
          ),
        ); });

        print("\n   markers.length: ${markers.length}");
      });
    }
  }
}
