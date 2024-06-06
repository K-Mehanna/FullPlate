import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/offer_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:flutter/services.dart'; // Add this import

class DonorDetailPage extends StatefulWidget {
  final DonorInfo donorInfo;

  DonorDetailPage({Key? key, required this.donorInfo}) : super(key: key);

  @override
  State<DonorDetailPage> createState() => _DonorDetailPageState();
}

class _DonorDetailPageState extends State<DonorDetailPage> {
  List<OfferInfo> openOffers = [];

  final DonorsManager donorsManager = DonorsManager();
  final OrdersManager ordersManager = OrdersManager();

  late final Map<String, ValueNotifier<int>> selectedQuantities;
  late final Map<String, TextEditingController> controllers;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Viewing Request"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ordersManager.acceptOpenOffer(
              widget.donorInfo.donorId,
              "vArN1MQqQfXSTTbgSP6MT5nzLz42",
              //FirebaseAuth.instance.currentUser!.uid,
              openOffers,
              openOffers
                  .map((offer) =>
                      selectedQuantities[offer.offerId]!.value)
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
            _buildDetailRow("Donor name", widget.donorInfo.name),
            SizedBox(height: 16),
            _buildDetailRow("Donor address", widget.donorInfo.address),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Category",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Quantity",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: 16),
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
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  ListView _buildOfferItemSelection(List<OfferInfo> items) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final offer = items[index];
        var selected = selectedQuantities[offer.offerId]!;
        var controller = controllers[offer.offerId]!;

        return ListTile(
          title: Text(offer.category.value),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    } else if (intValue != null && intValue > offer.quantity) {
                      controller.text = offer.quantity.toString();
                    } else if (intValue != null && intValue < 0) {
                      controller.text = "0";
                    } else if (intValue == null) {
                      controller.text = selected.value.toString();
                    }
                  },
                  onSubmitted: (value) {
                    int? intValue = int.tryParse(value);
                    if (intValue != null &&
                        intValue >= 0 &&
                        intValue <= offer.quantity) {
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
        );
      },
    );
  }
}
