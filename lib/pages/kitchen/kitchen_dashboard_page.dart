import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/pages/kitchen/job_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/database/donors_manager.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class KitchenDashboardPage extends StatefulWidget {
  KitchenDashboardPage({super.key});

  @override
  KitchenDashboardPageState createState() => KitchenDashboardPageState();
}

class KitchenDashboardPageState extends State<KitchenDashboardPage> {
  final OrdersManager ordersManager = OrdersManager();

  Map<String, DonorInfo> donorsInfo = {};
  List<JobInfo> acceptedJobs = [];

  final String kitchenId =
      "vArN1MQqQfXSTTbgSP6MT5nzLz42"; //FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    ordersManager.setJobsListener(OrderStatus.ACCEPTED, null, kitchenId,
        (newAccepted) {
      processDonorsInfo(newAccepted);
      if (!mounted) return;
      setState(() {
        acceptedJobs.clear();
        acceptedJobs.addAll(newAccepted);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildSectionTitle("Active Jobs", acceptedJobs.length),
                  ...acceptedJobs.map(buildJobItem)
                ])
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void processDonorsInfo(List<JobInfo> orders) {
    for (var order in orders) {
      assert(order.status == OrderStatus.ACCEPTED);

      DonorsManager().getDonorCompletion(order.donorId, (donor) {
        if (!mounted) return;
        setState(() {
          donorsInfo[order.donorId] = donor;
        });
      });
    }
  }

  Widget buildJobItem(JobInfo job) {
    return ListTile(
      leading: Icon(Icons.person),
      title: Text(donorsInfo[job.donorId]?.name ?? "..."),
      trailing: Text("x${job.quantity}"),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailPage(job: job),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Text("$title ($count)",
        style: TextStyle(fontWeight: FontWeight.bold));
  }
}
