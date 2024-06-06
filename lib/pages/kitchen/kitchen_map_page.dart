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
  late LocationPermission permission = LocationPermission.denied;
  late GoogleMapController mapController;

  static LatLng currentPosition = LatLng(51.4988, -0.176894); // LatLng(51.5032, 0.1195);
  late List<DonorInfo> donors = [];
  late Set<Marker> markers = {};
  OrderCategory? filters = OrderCategory.FRUIT_VEG;
  String? sortBy = 'Sort By';

  void getCurrentLocation(void Function(Position) callback) async {
    print('original: $permission');
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      print('new permission: $permission');

      if (!mounted) {
        return;
      }
      setState(() {
        this.permission = permission;
      });
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
        title: const Text('Available donors'),
        elevation: 2,
      ),
      body: SlidingUpPanel(
        color: Colors.blueGrey.shade50,
        snapPoint: 0.5,
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
          mapType: MapType.terrain,
          onMapCreated: _onMapCreated,
          padding: EdgeInsets.only(
            bottom: 250,
          ),
          initialCameraPosition: CameraPosition(
            target: currentPosition,
            zoom: 15.0,
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
            'Available donors',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Radius'),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.radar),
                  ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Category'),
                  SizedBox(width: 6),
                  DropdownButton(
                    value: filters,
                    items: OrderCategory.values.map((OrderCategory o) {
                      return DropdownMenuItem(
                        value: o,
                        child: o.icon, //Text(o.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (OrderCategory? category) {
                      setState(() {
                        filters = category!;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  DropdownButton(
                    value: sortBy,
                    items: ['Sort By', 'Distance', 'Recent'].map((String s) {
                      return DropdownMenuItem(
                        value: s,
                        enabled: s != 'Sort By',
                        child: Text(
                          s,
                          style: s != 'Sort By'
                              ? TextStyle(color: Colors.black)
                              : TextStyle(color: Colors.grey),
                        ), //Text(o.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (String? s) {
                      setState(() {
                        sortBy = s!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
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

    // BitmapDescriptor.asset(
    //         ImageConfiguration(size: Size(10, 10)), 'assets/store_logo.png')
    //     .then((image) {
    for (var donor in donorList) {
      setState(() {
        markers.add(
          Marker(
            //icon: image,
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
    }
  }
  //);
}

  // Future<BitmapDescriptor> iconDataToBitmapDescriptorSync(IconData iconData, {double size = 100}) async {
  //   final PictureRecorder recorder = PictureRecorder();
  //   final Canvas canvas = Canvas(recorder);

  //   final TextPainter textPainter = TextPainter(
  //     textDirection: TextDirection.ltr,
  //   );
  //   textPainter.text = TextSpan(
  //     text: String.fromCharCode(iconData.codePoint),
  //     style: TextStyle(
  //       color: Colors.black, // Change the color as needed
  //       fontSize: size,
  //       fontFamily: iconData.fontFamily,
  //     ),
  //   );

  //   textPainter.layout();
  //   textPainter.paint(canvas, Offset(0, 0));

  //   final ui.Image image = recorder.endRecording().toImage(size.toInt(), size.toInt());

  //   final ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   final Uint8List pngBytes = byteData.buffer.asUint8List();

  //   return BitmapDescriptor.fromBytes(pngBytes);
  // }
