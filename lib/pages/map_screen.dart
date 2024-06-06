import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  MapScreen({super.key, this.hasAppBar = false});

  final bool hasAppBar;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _center = const LatLng(51.4988, -0.176894);

  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hasAppBar ? AppBar(title: Text('Browse Nearby Places')) : null,
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 14.0,
        ),
      ),
    );
  }
}

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key, this.hasAppBar = false});
//   final bool hasAppBar;
  
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   Completer<GoogleMapController> _controller = Completer();
//   static const LatLng _center = const LatLng(51.4988, -0.176894);
//   LatLng _currentPosition = _center;


//   @override
//   void initState() {
//     super.initState();
//     _startMovingMap();
//   }

//   void _startMovingMap() {
//     Timer.periodic(Duration(seconds: 5), (timer) {
//       _moveMapRandomly();
//     });
//   }

//   void _moveMapRandomly() async {
//     final Random random = Random();
//     final double lat = _currentPosition.latitude + (random.nextDouble() - 0.5) * 0.1;
//     final double lng = _currentPosition.longitude + (random.nextDouble() - 0.5) * 0.1;
//     final LatLng newPosition = LatLng(lat, lng);

//     final GoogleMapController controller = await _controller.future;

//     controller.animateCamera(CameraUpdate.newLatLng(newPosition));

//     setState(() {
//       _currentPosition = newPosition;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: widget.hasAppBar ? AppBar(title: Text('Browse Nearby Places')) : null,
//       body: GoogleMap(
//         onMapCreated: (GoogleMapController controller) {
//           _controller.complete(controller);
//         },
//         initialCameraPosition: CameraPosition(
//           target: _center,
//           zoom: 14.0,
//         ),
//       ),
//     );
//   }
// }
