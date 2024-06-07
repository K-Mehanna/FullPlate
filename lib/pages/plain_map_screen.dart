import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlainMapScreen extends StatefulWidget {
  PlainMapScreen({super.key, this.hasAppBar = false});

  final bool hasAppBar;

  @override
  State<PlainMapScreen> createState() => _PlainMapScreenState();
}

class _PlainMapScreenState extends State<PlainMapScreen> {
  final LatLng _center = const LatLng(51.4988, -0.176894);

  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          widget.hasAppBar ? AppBar(title: Text('Browse Nearby Places')) : null,
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 14.0,
        ),
        zoomControlsEnabled: false,
      ),
    );
  }
}
