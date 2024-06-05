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
  DonorInfo? donor; // should display donor
  KitchenInfo? kitchen; // should display kitchen
  List<OfferInfo> constituentOffers = [];

  @override
  void initState() {
    super.initState();

    DonorsManager().getDonorCompletion(widget.job.donorId, (donor) {
      if (!mounted) {
        return; // to avoid calling setState after dispose (if the widget is disposed
      }
      setState(() {
        this.donor = donor;
      });
    });

    KitchensManager().getKitchenCompletion(widget.job.kitchenId, (kitchen) {
      if (!mounted) {
        return; // to avoid calling setState after dispose (if the widget is disposed
      }
      setState(() {
        this.kitchen = kitchen;
      });
    });

    OrdersManager().getConstituentOffersCompletion(widget.job.jobId, (offers) {
      if (!mounted) {
        return; // to avoid calling setState after dispose (if the widget is disposed
      }
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
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              heroTag: "job-complete",
              onPressed: () {
                OrdersManager().setJobCompleted(widget.job, () {
                  Navigator.pop(context);
                });
              },
              icon: Icon(Icons.check, color: Colors.white),
              label:
                  Text("Job Complete", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            SizedBox(width: 30),
            FloatingActionButton.extended(
              heroTag: "job-cancel",
              onPressed: () {
                OrdersManager().cancelJob(widget.job, () {
                  Navigator.pop(context);
                });
              },
              icon: Icon(Icons.cancel, color: Colors.white),
              label: Text("Cancel Job", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                "Kitchen", kitchen?.name ?? "--"), //todo kitchen details
            _buildDetailRow("Address", kitchen?.address ?? "--"),
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
