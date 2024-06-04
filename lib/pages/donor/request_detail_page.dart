import 'package:cibu/database/kitchens_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/models/kitchen_info.dart';
import 'package:cibu/models/offer_info.dart';
import 'package:flutter/material.dart';

class RequestDetailPage extends StatefulWidget {
  final JobInfo job;

  const RequestDetailPage({super.key, required this.job});

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  KitchenInfo? kitchen; // should display donor
  List<OfferInfo> constituentOffers = [];

  @override
  void initState() {
    super.initState();

    KitchensManager().getKitchenCompletion(widget.job.kitchenId, (kitchen) {
      setState(() {
        this.kitchen = kitchen;
      });
    });

    OrdersManager().getConstituentOffersCompletion(widget.job.jobId, (offers) {
      setState(() {
        constituentOffers = offers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Viewing Job"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                "Kitchen", kitchen?.name ?? "--"), //todo kitchen details
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn("Quantity", "${widget.job.quantity}"),
                _buildDetailColumn("Status", widget.job.status.value),
              ],
            ),
            _buildListItem(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool withIcon = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        if (withIcon)
          Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 8),
              Text(value),
            ],
          )
        else
          Text(value),
      ],
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  ListView _buildListItem() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: constituentOffers.length,
      itemBuilder: (context, index) {
        final offer = constituentOffers[index];

        return ListTile(
          leading: offer.category.icon,
          title: Text(offer.category.value.toString()),
          trailing: Text(offer.quantity.toString()),
        );
      },
    );
  }
}
