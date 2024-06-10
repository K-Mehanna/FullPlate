import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/pages/kitchen/job_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/database/donors_manager.dart';

class KitchenDashboardPage extends StatefulWidget {
  KitchenDashboardPage({super.key});

  @override
  KitchenDashboardPageState createState() => KitchenDashboardPageState();
}

class KitchenDashboardPageState extends State<KitchenDashboardPage> {
  final OrdersManager ordersManager = OrdersManager();

  Map<String, DonorInfo> donorsInfo = {};
  List<JobInfo> acceptedJobs = [];

  final _auth = FirebaseAuth.instance;

  late final String
      kitchenId; //= "vArN1MQqQfXSTTbgSP6MT5nzLz42"; //FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    kitchenId = _auth.currentUser!.uid;

    ordersManager.setJobsListener(OrderStatus.ACCEPTED, null, kitchenId,
        (newAccepted) {
      processDonorsInfo(newAccepted);
      if (!mounted) return;
      setState(() {
        if (!mounted) return;
        acceptedJobs.clear();
        acceptedJobs.addAll(newAccepted);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard",
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
            _buildSectionTitle("Active Jobs", acceptedJobs.length),
            Expanded(
              child: ListView.builder(
                itemCount: acceptedJobs.length,
                itemBuilder: (context, index) {
                  return buildJobItem(acceptedJobs[index]);
                },
              ),
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
          if (!mounted) return;
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
    return Text(
      "$title ($count)",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }
}
