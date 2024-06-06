import 'package:cibu/database/kitchens_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/models/kitchen_info.dart';
import 'package:cibu/pages/title_page.dart';
import 'package:cibu/pages/donor/job_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DonorProfilePage extends StatefulWidget {
  const DonorProfilePage({super.key});

  @override
  State<DonorProfilePage> createState() => _DonorProfilePageState();
}

class _DonorProfilePageState extends State<DonorProfilePage> {
  final OrdersManager ordersManager = OrdersManager();
  List<JobInfo> completedJobs = [];
  Map<String, KitchenInfo> kitchensInfo = {};

  @override
  void initState() {
    super.initState();
    fetchCompletedJobs();
  }

  void fetchCompletedJobs() {
    //final user = FirebaseAuth.instance.currentUser;
    const user = "HAO9gLWbTaT7z16pBoLGz019iSC3";
    ordersManager.getJobsCompletion(
      OrderStatus.COMPLETED,
      user,
      null,
      (jobs) {
        setState(() {
          completedJobs = jobs;
        });
        for (var job in jobs) {
          KitchensManager().getKitchenCompletion(job.kitchenId, (kitchen) {
            setState(() {
              kitchensInfo[kitchen.kitchenId] = kitchen;
            });
          });
        }
      },
    );
  }

  void _signOut() {
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TitlePage()),
      );
    });
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
              itemCount: completedJobs.length,
              itemBuilder: (context, index) {
                final job = completedJobs[index];
                return ListTile(
                  title: Text(kitchensInfo[job.kitchenId]?.name ?? "--"),
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
