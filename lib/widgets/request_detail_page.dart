import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/models/offer_info.dart';
import 'package:flutter/material.dart';

class RequestDetailPage extends StatefulWidget {
  final JobInfo job;

  const RequestDetailPage({super.key, required this.job});

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  DonorInfo? donor; // should display donor
  List<OfferInfo> constituentOffers = [];

  @override
  void initState() {
    super.initState();

    DonorsManager().getDonorCompletion(widget.job.donorId, (donor) {
      setState(() {
        this.donor = donor;
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Mark job as completed
          
          print('job ${widget.job.jobId} accepted');
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
            _buildDetailRow(
                "Donor", donor?.name ?? "--"), //todo kitchen details
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
