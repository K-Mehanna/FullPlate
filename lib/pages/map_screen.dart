import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/kitchens_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/models/kitchen_info.dart';
import 'package:cibu/pages/kitchen/donor_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapScreen extends StatefulWidget {
  MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final OrdersManager ordersManager = OrdersManager();
  final KitchensManager kitchensManager = KitchensManager();
  late GoogleMapController mapController;

  static LatLng currentPosition =
      LatLng(51.4988, -0.176894); // LatLng(51.5032, 0.1195);
  late List<KitchenInfo> kitchens = [];
  late Set<Marker> markers = {};

  void getCurrentLocation(void Function(Position) callback) async {
    _determineCurrentPosition().then(callback,
        onError: (e) => print("An error occured fetching location:\n$e"));
  }

  Future<Position> _determineCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    print('in here');

    kitchensManager.getAllKitchensCompletion(createMarkers);

    getCurrentLocation((newLocation) {
      var newPosition = LatLng(newLocation.latitude, newLocation.longitude);
      if (!mounted) {
        return;
      }

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
        title: const Text('Browse nearby charities'),
        elevation: 2,
      ),
      body: SlidingUpPanel(
        color: Colors.blueGrey.shade50,
        snapPoint: 0.5,
        minHeight: 65.0,
        maxHeight: 550.0,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        panelBuilder: (ScrollController sc) => _ordersScrollingList(sc),
        body: GoogleMap(
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          mapType: MapType.terrain,
          onMapCreated: _onMapCreated,
          padding: EdgeInsets.only(
            bottom: 150,
          ),
          initialCameraPosition: CameraPosition(
            target: currentPosition,
            zoom: 15.5,
          ),
          markers: markers,
        ),
      ),
    );
  }

  Widget _ordersScrollingList(ScrollController sc) {
    return Column(
      children: [
        Icon(Icons.keyboard_arrow_up),
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Text(
            'Available charities near you',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: sc,
            shrinkWrap: true,
            itemCount: kitchens.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) =>
                  //         DonorDetailPage(donorInfo: donors[index]),
                  //   ),
                  // );
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
                        kitchens[index].name,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(kitchens[index].address),
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

  double _distanceBetween(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  void createMarkers(List<KitchenInfo> kitchenList) {
    print('kitchens: $kitchens');
    print("\nKitchenMapPageState - createMarkers()\n");
    setState(() {
      markers.clear();

      kitchenList.sort((a, b) => _distanceBetween(a.location, currentPosition)
          .compareTo(_distanceBetween(b.location, currentPosition)));

      kitchens = kitchenList;
      print('kitchens: $kitchens');
    });

    for (var kitchen in kitchenList) {
      setState(() {
        markers.add(
          Marker(
            //icon: image,
            markerId: MarkerId(kitchen.kitchenId),
            position: kitchen.location,
            infoWindow: InfoWindow(
              title: kitchen.name,
              snippet: kitchen.address,
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => DonorDetailPage(kitchen: kitchen),
                //   ),
                // );
              },
            ),
          ),
        );
      });
    }
  }
  //);
}
