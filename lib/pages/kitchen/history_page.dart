import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/kitchens_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:flutter/material.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/pages/kitchen/job_detail_page_for_history.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatefulWidget {
  //final Map<String, DonorInfo> donorsInfo;

  HistoryPage({
    Key? key,
    //required this.completedJobs,
    //required this.donorsInfo,
  }) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<JobInfo> _completedJobs = [];
  Map<String, DonorInfo> _donorsInfo = {};
  final OrdersManager _ordersManager = OrdersManager();
  final DonorsManager _donorsManager = DonorsManager();
  //final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    _ordersManager.setCompletedJobsListener(
        null, FirebaseAuth.instance.currentUser!.uid, (jobs) {
      jobs.sort((a, b) => b.timeCompleted!.compareTo(a.timeCompleted!));
      if (!mounted) return;
      setState(() {
        _completedJobs = jobs;
      });
      for (var job in jobs) {
        _donorsManager.getDonorCompletion(job.donorId, (donor) {
          if (!mounted) return;
          setState(() {
            _donorsInfo[donor.donorId] = donor;
          });
        });
      }
    });
  }

  String getDate(JobInfo job) {
    final time = job.timeCompleted;
    if (time == null) {
      return "--";
    }
    var year = time.year;
    var month = time.month;
    var day = time.day;

    return "$day ${DateFormat('MMMM').format(DateTime(0, month))} $year";
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _completedJobs.length,
          itemBuilder: (context, index) {
            final job = _completedJobs[index];
            String date = getDate(job);
            return Card(
              color: theme.colorScheme.tertiaryContainer,
              shadowColor: theme.colorScheme.inversePrimary,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 7.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                shape: ShapeBorder.lerp(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  0.5,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                title: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 18,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _donorsInfo[job.donorId]?.name ?? "--",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onTertiaryContainer,
                          fontSize: 18),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.numbers,
                            size: 16,
                            color: theme.colorScheme.onTertiaryContainer),
                        const SizedBox(width: 4),
                        Text(
                          "Quantity: ${job.quantity}",
                          style: TextStyle(
                              color: theme.colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.date_range,
                            size: 16,
                            color: theme.colorScheme.onTertiaryContainer),
                        const SizedBox(width: 4),
                        Text(
                          "Collected on: $date",
                          style: TextStyle(
                              color: theme.colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailPage(job: job),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
