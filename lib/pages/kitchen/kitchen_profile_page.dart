import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/pages/kitchen/job_detail_page.dart';
import 'package:cibu/pages/title_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class KitchenProfilePage extends StatefulWidget {
  const KitchenProfilePage({super.key});

  @override
  State<KitchenProfilePage> createState() => _KitchenProfilePageState();
}

class _KitchenProfilePageState extends State<KitchenProfilePage> {
  final OrdersManager ordersManager = OrdersManager();
  List<JobInfo> completedJobs = [];
  Map<String, DonorInfo> donorsInfo = {};

  @override
  void initState() {
    super.initState();
    fetchCompletedJobs();
  }

  void fetchCompletedJobs() {
    ordersManager.getJobsCompletion(
        OrderStatus.COMPLETED,
        null,
        // FirebaseAuth.instance.currentUser!.uid,
        "vArN1MQqQfXSTTbgSP6MT5nzLz42", (jobs) {
      setState(() {
        completedJobs = jobs;
        print("jobs length ${completedJobs.length}");
      });
      for (var job in jobs) {
        DonorsManager().getDonorCompletion(job.donorId, (donor) {
          setState(() {
            donorsInfo[donor.donorId] = donor;
            print("donor thing ${donor.name}");
          });
        });
      }
    });
  }

  void _signOut() {
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TitlePage()),
      );
    });
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => TitlePage()
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _signOut,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Sign Out"),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: completedJobs
                  .length, // Use completedJobs instead of completedOffers
              itemBuilder: (context, index) {
                final job = completedJobs[index];
                return ListTile(
                  title: Text(donorsInfo[job.donorId]?.name ?? "--"),
                  subtitle: Text("x${job.quantity} ${job.timeCompleted}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailPage(job: job),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
