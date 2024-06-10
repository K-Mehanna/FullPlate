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
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              // Wrapped kitchen details in a Card widget
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
                    _buildDetailRow("Kitchen", kitchen?.name ?? "--"),
                    _buildDetailRow("Address", kitchen?.address ?? "--"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailColumn(
                            "Quantity", "${widget.job.quantity}", null),
                        _buildDetailColumn("Status", widget.job.status.value,
                            getIconForStatus(widget.job.status)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text(
                    "Offers",
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildOfferList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Icon getIconForStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.ACCEPTED:
        return Icon(
          Icons.published_with_changes,
          color: Colors.blue,
        );
      case OrderStatus.CANCELLED:
        return Icon(
          Icons.cancel,
          color: Colors.red,
        );
      case OrderStatus.COMPLETED:
        return Icon(
          Icons.done,
          color: Colors.green,
        );
      case OrderStatus.PENDING:
        return Icon(
          Icons.pending,
          color: Colors.amber,
        );
    }
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

  Widget _buildDetailColumn(String label, String value, Icon? icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        icon == null
            ? Text(value, style: TextStyle(fontSize: 16))
            : Row(
                children: [
                  Text(value, style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  icon,
                ],
              ),
      ],
    );
  }

  Widget _buildOfferList() {
    final ThemeData theme = Theme.of(context);
    return Expanded(
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
              ),
              title: Text(offer.category.value.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(offer.quantity.toString(),
                  style: TextStyle(fontSize: 16)),
            ),
          );
        },
      ),
    );
  }
}
