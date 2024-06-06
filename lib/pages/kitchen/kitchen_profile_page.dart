import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/pages/title_page.dart';
import 'package:cibu/pages/kitchen/history_page.dart';

class KitchenProfilePage extends StatefulWidget {
  const KitchenProfilePage({super.key});

  @override
  State<KitchenProfilePage> createState() => _KitchenProfilePageState();
}

class _KitchenProfilePageState extends State<KitchenProfilePage> {
  final OrdersManager _ordersManager = OrdersManager();
  List<JobInfo> _completedJobs = [];
  Map<String, DonorInfo> _donorsInfo = {};

  // Hard-coded user information for demonstration
  String _name = "John Doe";
  String _address = "123 Main St";
  String _email = "johndoe@example.com";

  @override
  void initState() {
    super.initState();
    _fetchCompletedJobs();
  }

  void _fetchCompletedJobs() {
    _ordersManager.getJobsCompletion(
      OrderStatus.COMPLETED,
      null,
      //"vArN1MQqQfXSTTbgSP6MT5nzLz42",
      FirebaseAuth.instance.currentUser!.uid,
      (jobs) {
        setState(() {
          _completedJobs = jobs;
        });
        for (var job in jobs) {
          DonorsManager().getDonorCompletion(job.donorId, (donor) {
            setState(() {
              _donorsInfo[donor.donorId] = donor;
            });
          });
        }
      },
    );
  }

  void _signOut() {
    FirebaseAuth.instance.signOut().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TitlePage()),
      );
    });
  }

  void _navigateToHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(
          completedJobs: _completedJobs,
          donorsInfo: _donorsInfo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
                _name,
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
                _address,
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
                _email,
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
