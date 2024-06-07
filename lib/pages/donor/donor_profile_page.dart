import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:flutter/material.dart';
import 'package:cibu/database/kitchens_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/models/kitchen_info.dart';
import 'package:cibu/pages/title_page.dart';
import 'history_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonorProfilePage extends StatefulWidget {
  const DonorProfilePage({super.key});

  @override
  State<DonorProfilePage> createState() => _DonorProfilePageState();
}

class _DonorProfilePageState extends State<DonorProfilePage> {
  final OrdersManager ordersManager = OrdersManager();
  List<JobInfo> completedJobs = [];
  Map<String, KitchenInfo> kitchensInfo = {};
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DonorInfo? donor; // should display donor


  @override
  void initState() {
    super.initState();
    fetchCompletedJobs();

    DonorsManager().getDonorCompletion(_auth.currentUser!.uid, (donor) {
      setState(() {
        this.donor = donor;
      });
    });
  }

  void fetchCompletedJobs() {
    final user = FirebaseAuth.instance.currentUser;
    //const user = "HAO9gLWbTaT7z16pBoLGz019iSC3";
    ordersManager.getJobsCompletion(
      OrderStatus.COMPLETED,
      user!.uid,
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

  void _navigateToHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(
          completedJobs: completedJobs,
          kitchensInfo: kitchensInfo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                "Name",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              subtitle: Text(
                donor?.name ?? '', // Placeholder name
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            ListTile(
              title: Text(
                "Address",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              subtitle: Text(
                donor?.address ?? '', // Placeholder address
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            ListTile(
              title: Text(
                "Email",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              subtitle: Text(
                _auth.currentUser!.email!, // Placeholder email
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.history, color: Colors.white),
                onPressed: _navigateToHistoryPage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                label: Text(
                  "View History",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.logout, color: Colors.black),
                onPressed: _signOut,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                label: Text(
                  "Sign Out",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
