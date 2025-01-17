import 'dart:convert';

import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/offer_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';

class DonorDetailPage extends StatefulWidget {
  final DonorInfo donorInfo;
  //final LatLng currentPosition;

  DonorDetailPage({
    Key? key,
    required this.donorInfo,
    //required this.currentPosition,
  }) : super(key: key);

  @override
  State<DonorDetailPage> createState() => _DonorDetailPageState();
}

class _DonorDetailPageState extends State<DonorDetailPage> {
  List<OfferInfo> openOffers = [];
  ValueNotifier<Map<String, dynamic>> carStats =
      ValueNotifier<Map<String, dynamic>>(
    {
      "distance": {"text": "...", "value": 0},
      "duration": {"text": "...", "value": 0},
    },
  );
  ValueNotifier<Map<String, dynamic>> walkingStats =
      ValueNotifier<Map<String, dynamic>>(
    {
      "distance": {"text": "...", "value": 0},
      "duration": {"text": "...", "value": 0},
    },
  );
  LatLng? currentPosition;

  final DonorsManager donorsManager = DonorsManager();
  final OrdersManager ordersManager = OrdersManager();

  late final Map<String, ValueNotifier<int>> selectedQuantities;
  late final Map<String, TextEditingController> controllers;
  late ThemeData theme;

  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    ordersManager.getOpenOffersCompletion(widget.donorInfo.donorId,
        (newOffers) {
      setState(() {
        openOffers.addAll(newOffers);

        selectedQuantities = {
          for (var offer in openOffers)
            offer.offerId: ValueNotifier<int>(offer.quantity),
        };

        controllers = {
          for (var offer in openOffers)
            offer.offerId:
                TextEditingController(text: offer.quantity.toString()),
        };
      });
    });

    getCurrentLocation((newLocation) {
      var newPosition = LatLng(newLocation.latitude, newLocation.longitude);
      if (!mounted) {
        return;
      }

      setState(() {
        currentPosition = newPosition;
      });

      getDistanceMatrix((cStats, wStats) {
        if (!mounted) {
          return;
        }
        setState(() {
          carStats.value = cStats;
          walkingStats.value = wStats;
        });
      });
    });
  }

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

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => MapsLauncher.launchQuery(widget.donorInfo.address),
            icon: Icon(Icons.map),
            color: theme.colorScheme.primary,
          )
        ],
        title: Text(
          "Viewing Request",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ordersManager.acceptOpenOffer(
              widget.donorInfo.donorId,
              _auth.currentUser!.uid,
              openOffers,
              openOffers
                  .map((offer) => selectedQuantities[offer.offerId]!.value)
                  .toList(), () {
            Navigator.pop(context);
          });
        },
        label: Text("Accept order"),
        icon: Icon(
          Icons.check,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
                color: theme.colorScheme.surfaceContainer,
                elevation: 5,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () =>
                      MapsLauncher.launchQuery(widget.donorInfo.address),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow("Donor name", widget.donorInfo.name),
                        SizedBox(height: 16),
                        _buildDetailRow(
                            "Donor address", widget.donorInfo.address),
                        SizedBox(height: 16),
                        Text(
                          "Distance/time to donor",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // SizedBox(
                            //   width: 5,
                            // ),
                            Icon(
                              Icons.directions_car,
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Text(
                              carStats.value["distance"]["text"],
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Text(
                              carStats.value["duration"]["text"],
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // SizedBox(
                            //   width: 5,
                            // ),
                            Icon(
                              Icons.directions_walk,
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Text(
                              walkingStats.value["distance"]["text"],
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Text(
                              walkingStats.value["duration"]["text"],
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // _buildDetailRow("Donor name", widget.donorInfo.name),
            // SizedBox(height: 16),
            // _buildDetailRow("Donor address", widget.donorInfo.address),
            // SizedBox(height: 16),

            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Category",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Spacer(
                    flex: 3,
                  ),
                  Text("Expiry", style: TextStyle(fontWeight: FontWeight.bold)),
                  Spacer(
                    flex: 2,
                  ),
                  Text("Quantity",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(child: _buildOfferItemSelection(openOffers)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(value, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  void getDistanceMatrix(
      void Function(Map<String, dynamic>, Map<String, dynamic>) callback) {
    LatLng dest = widget.donorInfo.location;
    LatLng src = currentPosition!;
    String key = "AIzaSyDusgS3hbLeajpaVitxr7rEol3AJHmr5-4";
    Map<String, dynamic> carStats;
    Map<String, dynamic> walkStats;
    try {
      Dio()
          .get(
              'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${dest.latitude},${dest.longitude}&origins=${src.latitude},${src.longitude}&key=$key')
          .then((value) {
        final user = jsonDecode(value.toString()) as Map<String, dynamic>;
        carStats = user["rows"][0]["elements"][0];
        if (carStats.length == 1) {
          carStats = {
            "distance": {"text": "Cannot get distance", "value": 0},
            "duration": {"text": "Cannot get time", "value": 0},
          };
        }
        print(carStats);

        try {
          Dio()
              .get(
                  'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${dest.latitude},${dest.longitude}&origins=${src.latitude},${src.longitude}&mode=walking&key=$key')
              .then((value) {
            final user = jsonDecode(value.toString()) as Map<String, dynamic>;
            walkStats = user["rows"][0]["elements"][0];
            if (walkStats.length == 1) {
              walkStats = {
                "distance": {"text": "Cannot get distance", "value": 0},
                "duration": {"text": "Cannot get time", "value": 0},
              };
            }
            print(walkStats);
            callback(carStats, walkStats);
          });
        } catch (e) {
          print(e);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  ListView _buildOfferItemSelection(List<OfferInfo> items) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final offer = items[index];
        var selected = selectedQuantities[offer.offerId]!;
        var controller = controllers[offer.offerId]!;

        return Card(
          elevation: 3,
          color: theme.colorScheme.inversePrimary,
          child: ListTile(
            title: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                offer.category.value,
                style:
                    // theme.textTheme.titleLarge!.copyWith(
                    //   fontWeight: FontWeight.bold,
                    //   //color: theme.colorScheme.onSecondary,
                    // ),
                    TextStyle(
                  fontWeight: FontWeight.w500,
                  //color: theme.colorScheme.onSecondary,
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hourglass_bottom_rounded,
                ),
                Text(offer.getExpiryDescription()),
                //SizedBox(width: 16),
                ValueListenableBuilder<int>(
                  valueListenable: selected,
                  builder: (context, value, _) {
                    return IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: (value > 0)
                          ? () {
                              selected.value--;
                              controller.text = selected.value.toString();
                            }
                          : null,
                    );
                  },
                ),
                SizedBox(
                  width: 25, // Adjust width as necessary
                  child: TextField(
                    decoration: InputDecoration.collapsed(
                      hintText: '',
                    ),
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (value) {
                      int? intValue = int.tryParse(value);
                      if (intValue != null &&
                          intValue >= 0 &&
                          intValue <= offer.quantity) {
                        selected.value = intValue;
                      } else if (intValue != null &&
                          intValue > offer.quantity) {
                        controller.text = offer.quantity.toString();
                      } else if (intValue != null && intValue < 0) {
                        controller.text = "0";
                      }
                    },
                    onSubmitted: (value) {
                      int? intValue = int.tryParse(value);
                      if (intValue != null) {
                        selected.value = intValue;
                      } else {
                        controller.text =
                            selected.value.toString(); // Reset to valid value
                      }
                    },
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: selected,
                  builder: (context, value, _) {
                    return IconButton(
                      icon: Icon(Icons.add),
                      onPressed: (value < offer.quantity)
                          ? () {
                              selected.value++;
                              controller.text = selected.value.toString();
                            }
                          : null,
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class DonorInfoCard extends StatelessWidget {
  const DonorInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card();
  }
}
