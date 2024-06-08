import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/pages/donor/donor_home_page.dart';
import 'package:cibu/widgets/custom_button.dart';
import 'package:cibu/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:cibu/pages/auth/address_autocomplete/address_search.dart';
import 'package:cibu/pages/auth/address_autocomplete/address_service.dart';

class DonorSignupPage extends StatefulWidget {
  const DonorSignupPage({super.key});

  @override
  State<DonorSignupPage> createState() => _DonorSignupPageState();
}

class _DonorSignupPageState extends State<DonorSignupPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final DonorsManager donorsManager = DonorsManager();

  LatLng? location;

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void updateDetailsToFirestore() {
    DonorInfo donorInfo = DonorInfo(
      name: nameController.text,
      location: location!, 
      address: addressController.text,
      donorId: _auth.currentUser!.uid, //"HAO9gLWbTaT7z16pBoLGz019iSC3", //FirebaseAuth.instance.currentUser!.uid,
      quantity: 0,
    );

    donorsManager.addDonor(donorInfo);
  }

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Donor Page'),
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
                  Spacer(),
                  Text(
                    'Thanks!\nWe still need a bit more info',
                    style: Theme.of(context).textTheme.headlineMedium!,
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
                                builder: (context) => DonorHomePage()
                          )
                        );
                      }
                    },
                    text: 'Next',
                  ),
                  Spacer(flex: 2,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
