import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/kitchens_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/models/kitchen_info.dart';
import 'package:cibu/models/offer_info.dart';
import 'package:flutter/material.dart';

class JobDetailPage extends StatefulWidget {
  final JobInfo job;

  const JobDetailPage({super.key, required this.job});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  DonorInfo? donor;
  KitchenInfo? kitchen;
  List<OfferInfo> constituentOffers = [];

  @override
  void initState() {
    super.initState();

    DonorsManager().getDonorCompletion(widget.job.donorId, (donor) {
      if (!mounted) {
        return;
      }
      setState(() {
        this.donor = donor;
      });
    });

    KitchensManager().getKitchenCompletion(widget.job.kitchenId, (kitchen) {
      if (!mounted) {
        return;
      }
      setState(() {
        this.kitchen = kitchen;
      });
    });

    OrdersManager().getConstituentOffersCompletion(widget.job.jobId, (offers) {
      if (!mounted) {
        return;
      }
      setState(() {
        constituentOffers = offers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Viewing Job",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Kitchen", kitchen?.name ?? "--"),
                    _buildDetailRow("Address", kitchen?.address ?? "--"),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailColumn(
                            "Quantity", "${widget.job.quantity}"),
                        _buildDetailColumn("Status", widget.job.status.value),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text("Offers", style: theme.textTheme.titleLarge),
                    SizedBox(height: 8),
                    _buildOfferList(),
                  ],
                ),
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
          Text(value, style: TextStyle(color: Colors.grey[900], fontSize: 16)),
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

  Widget _buildOfferList() {
    final ThemeData theme = Theme.of(context);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: constituentOffers.length,
      itemBuilder: (context, index) {
        final offer = constituentOffers[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            tileColor: theme.colorScheme.inversePrimary,
            leading: Icon(offer.category.icon.icon,
                color: Theme.of(context).colorScheme.onSurface),
            title: Text(offer.category.value.toString(),
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing:
                Text(offer.quantity.toString(), style: TextStyle(fontSize: 16)),
          ),
        );
      },
    );
  }
}
