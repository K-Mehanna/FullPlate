// import 'dart:async';

import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/models/offer_info.dart';
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
  static LatLng currentPosition = LatLng(51.5072, 0.1276);
  late List<DonorInfo> donors = [];
  late Set<Marker> markers = {};
  OrderCategory? filters = OrderCategory.FRUIT_VEG;
  String? sortBy = 'Sort By';

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
    print('in here');

    donorsManager.getDonorsCompletion(createMarkers);

    getCurrentLocation((newLocation) {
      var newPosition = LatLng(newLocation.latitude, newLocation.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(newPosition));
      if (!mounted) {
        return;
      }
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
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Container(
        //         child: Row(
        //           children: [
        //             Text('Radius'),
        //             Padding(
        //               padding: const EdgeInsets.all(4.0),
        //               child: Icon(Icons.radar),
        //             ),
        //             Container(
        //               width: 30,
        //               height: 30,
        //               child: TextField(
        //                 keyboardType: TextInputType.number,
        //                 decoration: InputDecoration(
        //                   border: OutlineInputBorder(),
        //                   contentPadding: EdgeInsets.symmetric(horizontal: 8),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //       Row(
        //         children: [
        //           Text('Category'),
        //           SizedBox(width: 6),
        //           DropdownButton(
        //             value: filters,
        //             items: OrderCategory.values.map((OrderCategory o) {
        //               return DropdownMenuItem(
        //                 value: o,
        //                 child: o.icon, //Text(o.toString().split('.').last),
        //               );
        //             }).toList(),
        //             onChanged: (OrderCategory? category) {
        //               setState(() {
        //                 filters = category!;
        //               });
        //             },
        //           ),
        //         ],
        //       ),
        //       Row(
        //         children: [
        //           DropdownButton(
        //             value: sortBy,
        //             items: ['Sort By', 'Distance', 'Recent'].map((String s) {
        //               return DropdownMenuItem(
        //                 value: s,
        //                 enabled: s != 'Sort By',
        //                 child: Text(
        //                   s,
        //                   style: s != 'Sort By'
        //                       ? TextStyle(color: Colors.black)
        //                       : TextStyle(color: Colors.grey),
        //                 ), //Text(o.toString().split('.').last),
        //               );
        //             }).toList(),
        //             onChanged: (String? s) {
        //               setState(() {
        //                 sortBy = s!;
        //               });
        //             },
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        Expanded(
          child: ListView.builder(
            controller: sc,
            shrinkWrap: true,
            itemCount: donors.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DonorDetailPage(donorInfo: donors[index]),
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
                        donors[index].name,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('x${donors[index].quantity}'),
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

  void createMarkers(List<DonorInfo> donorList) {
    print("\nKitchenMapPageState - createMarkers()\n");
    setState(() {
      markers.clear();
      donors = donorList;
      print('donors: $donors');
    });

    for (var donor in donorList) {
      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId(donor.donorId),
            position: donor.location,
            infoWindow: InfoWindow(
              title: donor.name,
              snippet: donor.address,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DonorDetailPage(donorInfo: donor),
                  ),
                );
              },
            ),
          ),
        );
      });

      print("\n   markers.length: ${markers.length}");
    }
  }
}
