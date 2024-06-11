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
    final ThemeData theme = Theme.of(context);
    // return ListTile(
    //   leading: Icon(Icons.person),
    //   title: Text(donorsInfo[job.donorId]?.name ?? "..."),
    //   trailing: Text("x${job.quantity}"),
    //   onTap: () {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => JobDetailPage(job: job),
    //       ),
    //     );
    //   },
    // );
    return Column(
      children: [
        Card(
          color: theme.colorScheme.inversePrimary,
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailPage(job: job),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8),
                  Text(
                    donorsInfo[job.donorId]?.name ?? "...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Text(
                    "x${job.quantity}",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
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
