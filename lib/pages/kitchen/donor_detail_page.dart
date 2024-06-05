import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/offer_info.dart';
import 'package:flutter/material.dart';
import 'package:cibu/models/donor_info.dart';

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

  // Map to store the selected quantities for each order item
  late final Map<String, ValueNotifier<int>> selectedQuantities;

  @override
  void initState() {
    super.initState();

    ordersManager.getOpenOffersCompletion(widget.donorInfo.donorId,
        (newOffers) {
      setState(() {
        openOffers.addAll(newOffers);

        selectedQuantities = {
          for (var order in openOffers) order.offerId: ValueNotifier<int>(0),
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
              //auth.currentUser!.uid
              "BgOtpuMuOZNa6IYWRJgb", // TODO: Replace with the actual kitchen ID // 
              openOffers,
              openOffers
                  .map((offer) => selectedQuantities[offer.offerId]!.value)
                  .toList());

          Navigator.pop(context);
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
        final selected = selectedQuantities[offer.offerId]!;

        return ListTile(
          title: Text(offer.category.value),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (selected.value > 0) {
                    selected.value--;
                  }
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: selected,
                builder: (context, value, _) {
                  return Text(value.toString());
                },
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  if (selected.value < offer.quantity) {
                    selected.value++;
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
