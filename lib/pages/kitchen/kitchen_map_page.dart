import 'dart:async';

import 'package:cibu/models/request_item.dart';
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
  late GoogleMapController mapController;
  late Future<Position> currentPositionFuture;

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
    currentPositionFuture = getCurrentLocation();
  }

  // void _addNewRequest() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => NewRequestPage(
  //         addRequestCallback: (RequestItem item) => {
  //           setState(() {
  //             pending.add(item);
  //           })
  //         },
  //       ),
  //     ),
  //   );
  // }

  List<Map<String, dynamic>> donors = [
    {
      'id': '1',
      'name': 'PAUL',
      'location': LatLng(51.4945, -0.1730),
    },
    {
      'id': '2',
      'name': 'Venchi',
      'location': LatLng(51.5012, -0.1775),
    },
  ];

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
              markers: createMarkers(),
            );
          } else {
            return Center(child: Text('Unable to get location'));
          }
        },
      ),
    );
  }

  final RequestItem item = RequestItem(
    title: "avocado",
    location: "",
    address: "",
    quantity: 0,
    size: "N/A",
    category: "Veg",
    claimed: false,
  );

  Set<Marker> createMarkers() {
    var markers = <Marker>{};
    for (var donor in donors) {
      markers.add(
        Marker(
          markerId: MarkerId(donor['id']),
          position: donor['location'],
          infoWindow: InfoWindow(
            title: '${donor['name']}',
            snippet: 'SIUUUUUUUUUUUUUUUUUUUUUUUUUUUU',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DonorDetailPage(item: item),
                ),
              );
            },
          ),
        ),
      );
    }
    return markers;
  }
}
