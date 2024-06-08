import 'package:cibu/database/kitchens_manager.dart';
import 'package:cibu/models/kitchen_info.dart';
import 'package:cibu/pages/kitchen/kitchen_home_page.dart';
import 'package:cibu/widgets/custom_button.dart';
import 'package:cibu/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:cibu/pages/auth/address_autocomplete/address_search.dart';
import 'package:cibu/pages/auth/address_autocomplete/address_service.dart';

class KitchenSignupPage extends StatefulWidget {
  const KitchenSignupPage({super.key});

  @override
  State<KitchenSignupPage> createState() => _KitchenSignupPageState();
}

class _KitchenSignupPageState extends State<KitchenSignupPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final KitchensManager kitchensManager = KitchensManager();

  LatLng? location;

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> markSignupAsComplete() async {
    try {
      await _db
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({
        'completedProfile': true,
      });
    } catch (e) {
      throw Exception("Error updating user profile: $e");
    }
  }

  void updateDetailsToFirestore() {
    KitchenInfo kitchenInfo = KitchenInfo(
      name: nameController.text,
      location: location!,
      address: addressController.text,
      kitchenId: _auth.currentUser!.uid
          //"vArN1MQqQfXSTTbgSP6MT5nzLz42", //FirebaseAuth.instance.currentUser!.uid
    );

    kitchensManager.addKitchen(kitchenInfo);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kitchen Page'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Thanks!\nWe still need a bit more info',
                      style: Theme.of(context).textTheme.headlineMedium!,
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    controller: nameController,
                    hintText: 'Organisation Name',
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  CustomTextField(
                      controller: addressController,
                      hintText: 'Address',
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an address';
                        }
                        return null;
                      },
                      onTap: () async {
                        // generate a new token here
                        final sessionToken = Uuid().v4();
          
                        final Suggestion? result = await showSearch(
                          context: context,
                          delegate: AddressSearch(sessionToken),
                        );
          
                        if (result != null && result.placeId.isNotEmpty) {
                          final addressCoords =
                              await PlaceApiProvider(sessionToken)
                                  .getPlaceDetailFromId(result.placeId);
                          setState(() {
                            addressController.text = result.description;
                            location = addressCoords;
                          });
                        }
                      }),
                  const SizedBox(height: 25),
                  CustomButton(
                    onTap: () {
                      if (formKey.currentState!.validate() && location != null) {
                        updateDetailsToFirestore();
                        markSignupAsComplete();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => KitchenHomePage()));
                      }
                    },
                    text: 'Next',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
