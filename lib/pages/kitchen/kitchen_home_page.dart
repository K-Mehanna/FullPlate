import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class KitchenHomePage extends StatefulWidget {
  KitchenHomePage({super.key});

  @override
  State<KitchenHomePage> createState() => _KitchenHomePageState();
}

class _KitchenHomePageState extends State<KitchenHomePage> {
  final Completer<GoogleMapController> _controller = Completer();
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

  List<Map<String, dynamic>> donors = [
    {
      'id': '1',
      'name': 'Gaza',
      'location': LatLng(31.5017, 34.4668),
    },
    {
      'id': '2',
      'name': 'Masjid Al Haram',
      'location': LatLng(21.4229, 39.8257),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
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
      ),
    );
  }

  Set<Marker> createMarkers() {
    var markers = <Marker>{};
    for (var donor in donors) {
      markers.add(
        Marker(
          markerId: MarkerId(donor['id']),
          position: donor['location'],
          infoWindow: InfoWindow(
            title: '${donor['name']}',
            snippet: 'SIUUUUUUU',
          ),
        ),
      );
    }
    return markers;
  }
}
