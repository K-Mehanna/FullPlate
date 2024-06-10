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
        constituentOffers.clear();

        Map<OrderCategory, int> categories =
            offers.map((o) => o.category).toSet().fold({}, (map, category) {
          map[category] = 0;
          return map;
        });

        for (var offer in offers) {
          categories[offer.category] =
              categories[offer.category]! + offer.quantity;
        }

        categories.forEach((category, quantity) {
          constituentOffers.add(OfferInfo(
              category: category,
              quantity: quantity,
              offerId: "unassigned",
              expiryDate: DateTime.now()));
        });
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
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Viewing Job",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _onShareWithResult,
            icon: Icon(Icons.share),
            color: theme.colorScheme.onSurface,
          ),
          IconButton(
            onPressed: () => MapsLauncher.launchQuery(donor!.address),
            icon: Icon(Icons.map),
            color: theme.colorScheme.onSurface,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: theme.colorScheme.surfaceContainer,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      "Donor",
                      donor?.name ?? "--",
                    ),
                    _buildDetailRow("Address", donor?.address ?? "--"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailColumn(
                            "Quantity", "${widget.job.quantity}"),
                        _buildDetailColumn("Status", widget.job.status.value),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Offers",
              style: theme.textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: constituentOffers.length,
                itemBuilder: (context, index) {
                  final offer = constituentOffers[index];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      tileColor: theme.colorScheme.inversePrimary,
                      leading: Icon(
                        offer.category.icon.icon,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        offer.category.value.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Text(
                        offer.quantity.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    // ignore: unused_local_variable
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value, style: TextStyle(color: Colors.grey[700], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(value, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
