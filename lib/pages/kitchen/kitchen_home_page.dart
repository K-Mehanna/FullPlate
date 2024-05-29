import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class KitchenHomePage extends StatefulWidget {
  KitchenHomePage({super.key});

  @override
  State<KitchenHomePage> createState() => _KitchenHomePageState();
}

class _KitchenHomePageState extends State<KitchenHomePage> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(31.9522, 35.2332);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          elevation: 2,
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          markers: {
            const Marker(
              markerId: MarkerId('Gaza'),
              position: LatLng(31.5017, 34.4668),
              infoWindow: InfoWindow(
                title: "Gaza",
                snippet: "SIUUUUUUU",
              ),
            )
          },
        ),
      ),
    );
  }
}
