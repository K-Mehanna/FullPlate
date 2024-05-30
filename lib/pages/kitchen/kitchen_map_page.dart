import 'dart:async';

import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/donor_info.dart';
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
  late Future<Position> currentPositionFuture;
  late List<OrderInfo> orders = [];
  late Set<Marker> markers = {};

  Future<Position> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("The position is $position");
    return position;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    ordersManager.getOrdersCompletion(
        OrderStatus.PENDING, false, null, null, createMarkers);
    currentPositionFuture = getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available donors'),
        elevation: 2,
      ),
      body: FutureBuilder<Position>(
        future: currentPositionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Position position = snapshot.data!;
            return GoogleMap(
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 16.0,
              ),
              markers: markers,
            );
          } else {
            return Center(child: Text('Unable to get location'));
          }
        },
      ),
    );
  }

  void createMarkers(List<OrderInfo> orders) {
    setState(() {
      for (var order in orders) {
        donorsManager.getDonorCompletion(order.donorId, (donor) {
          print(donor.address);
          print(donor.name);
          markers.add(
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
          );
        });
      }
    });
  }
}
