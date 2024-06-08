import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/models/offer_info.dart';
import 'package:cibu/pages/kitchen/donor_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:filter_list/filter_list.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class KitchenMapPage extends StatefulWidget {
  KitchenMapPage({super.key});

  @override
  State<KitchenMapPage> createState() => _KitchenMapPageState();
}

class _KitchenMapPageState extends State<KitchenMapPage> {
  final OrdersManager ordersManager = OrdersManager();
  final DonorsManager donorsManager = DonorsManager();
  late GoogleMapController mapController;

  static LatLng currentPosition =
      LatLng(51.4988, -0.176894); // LatLng(51.5032, 0.1195);
  late List<DonorInfo> donors = [];
  late Set<Marker> markers = {};
  OrderCategory? filters = OrderCategory.FRUIT_VEG;
  List<String> sortParams = ['Distance', 'Quantity', 'Recent'];
  String? sortParam;
  List<OrderCategory> selectedCategoryList = OrderCategory.values;

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

    donorsManager.getOfferDonorsCompletion(createMarkers);

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available donors'),
      ),
      body: SlidingUpPanel(
        color: theme.colorScheme.surface,
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
            bottom: 250,
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

  void openFilterDialog() async {
    await FilterListDialog.display<OrderCategory>(
      context,
      listData: OrderCategory.values,
      selectedListData: selectedCategoryList,
      choiceChipLabel: (category) => category!.value,
      validateSelectedItem: (list, val) => list!.contains(val),
      onItemSearch: (category, query) {
        return category.value.toLowerCase().contains(query.toLowerCase());
      },
      onApplyButtonClick: (list) {
        setState(() {
          selectedCategoryList = List.from(list!);
          donorsManager.getFilteredOfferDonorsCompletion(
              createMarkers, selectedCategoryList);
          print('selectedCategoryList: $selectedCategoryList');
        });
        Navigator.pop(context);
        // Redraw list
      },
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: openFilterDialog,
                    label: Text('Filters'),
                    icon: Icon(Icons.filter_alt),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      iconStyleData: IconStyleData(
                        iconSize: 18,
                      ),
                      isExpanded: false,
                      hint: Row(
                        children: [
                          Icon(Icons.sort),
                          SizedBox(width: 10),
                          Text(
                            'Sort by',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                      items: sortParams
                          .map(
                            (String item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      value: sortParam,
                      onChanged: (String? value) {
                        setState(() {
                          sortParam = value;
                          donorsManager.getFilteredOfferDonorsCompletion(
                              createMarkers, selectedCategoryList);
                        });
                      },
                      buttonStyleData: ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 40,
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.black26,
                          ),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        openInterval: const Interval(0.1, 0.25),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
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
                      builder: (context) => DonorDetailPage(
                        donorInfo: donors[index],
                      ),
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

  double _distanceBetween(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  void createMarkers(List<DonorInfo> donorList) {
    print('donors: $donorList');
    print("\nKitchenMapPageState - createMarkers()\n");
    setState(() {
      markers.clear();

      if (sortParam == 'Distance') {
        donorList.sort((a, b) => _distanceBetween(a.location, currentPosition)
            .compareTo(_distanceBetween(b.location, currentPosition)));
      } else if (sortParam == 'Quantity') {
        donorList.sort((a, b) => b.quantity.compareTo(a.quantity));
      } else if (sortParam == 'Recent') {
        //donorList.sort((a, b) => a..compareTo(b.createdAt));
      }

      donors = donorList;
      print('donors: $donors');
    });

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
                    builder: (context) => DonorDetailPage(
                      donorInfo: donor,
                    ),
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
