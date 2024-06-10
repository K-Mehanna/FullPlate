import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/models/offer_info.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:maps_launcher/maps_launcher.dart';

class JobDetailPage extends StatefulWidget {
  final JobInfo job;

  const JobDetailPage({super.key, required this.job});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
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

  void _onShareWithResult() {
    String donorName = donor?.name ?? "--";
    String donorAddress = donor?.address ?? "--";
    String h = "";
    OrdersManager().getConstituentOffersCompletion(widget.job.jobId,
        (offers) async {
      for (var offer in offers) {
        h += "${offer.category.value}  x${offer.quantity}\n";
      }
      await Share.share(
        'Here\'s the collection details:\n\nName: $donorName\nAddress: $donorAddress\n\nDetails:\n$h\nLink: https://maps.google.com/?q=${donorAddress.replaceAll(' ', '+')}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Viewing Job"),
        actions: [
          IconButton(
            onPressed: _onShareWithResult,
            icon: Icon(Icons.share),
          ),
          IconButton(
            onPressed: () => MapsLauncher.launchQuery(donor!.address),
            icon: Icon(Icons.map),
            color: theme.colorScheme.primary,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Donor", donor?.name ?? "--"),
            _buildDetailRow("Address", donor?.address ?? "--"),
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
