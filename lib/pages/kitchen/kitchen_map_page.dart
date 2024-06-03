import 'dart:async';

import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/order_info.dart';
import 'package:cibu/pages/kitchen/donor_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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

    position.then(callback,
        onError: (e) => print("An error occured fetching location:\n$e"));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    ordersManager.getOrdersCompletion(
        OrderStatus.PENDING, false, null, null, createMarkers);
    getCurrentLocation((newLocation) {
      var newPosition = LatLng(newLocation.latitude, newLocation.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(newPosition));
      setState(() {
        currentPosition = newPosition;
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
      body: SlidingUpPanel(
        color: Colors.blueGrey.shade50,
        minHeight: 65.0,
        maxHeight: 550.0,
        parallaxEnabled: true,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        panelBuilder: (ScrollController sc) => _ordersScrollingList(sc),
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
      ),
    );
  }

  Widget _ordersScrollingList(ScrollController sc) {
    return Column(
      children: [
        Icon(Icons.drag_handle),
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Text(
            'Available donors',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: sc,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DonorDetailPage(order: orders[index]),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  child: Row(
                    children: [
                      Text(
                        orders[index].name,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('Secondary text'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void createMarkers(List<OrderInfo> orderList) {
    print("\nKitchenMapPageState - createMarkers()\n");
    setState(() {
      markers.clear();
      orders = orderList;
      print('orders: $orders');
    });

    for (var order in orderList) {
      donorsManager.getDonorCompletion(order.donorId, (donor) {
        setState(() {
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

        print("\n   markers.length: ${markers.length}");
      });
    }
  }
}
