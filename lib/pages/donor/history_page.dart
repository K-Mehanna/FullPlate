import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/kitchens_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/models/kitchen_info.dart';
import 'package:cibu/pages/donor/job_detail_page_for_history.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({
    Key? key,
    // required this.completedJobs,
    // required this.kitchensInfo,
  }) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<JobInfo> _completedJobs = [];
  Map<String, KitchenInfo> _kitchenInfos = {};
  final OrdersManager _ordersManager = OrdersManager();
  final KitchensManager _kitchensManager = KitchensManager();
  //final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    _ordersManager.setCompletedJobsListener(
        FirebaseAuth.instance.currentUser!.uid, null, (jobs) {
      jobs.sort((a, b) => b.timeCompleted!.compareTo(a.timeCompleted!));
      if (!mounted) return;
      setState(() {
        _completedJobs = jobs;
      });
      for (var job in jobs) {
        _kitchensManager.getKitchenCompletion(job.kitchenId, (kitchen) {
          if (!mounted) return;
          setState(() {
            _kitchenInfos[kitchen.kitchenId] = kitchen;
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

    //return time.toString();
    return "$day ${DateFormat('MMMM').format(DateTime(0, month))} $year";
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
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
            final date = getDate(job);
            final kitchenName = _kitchenInfos[job.kitchenId]?.name ?? "--";
            return Card(
              color: theme.colorScheme.tertiaryContainer,
              shadowColor: theme.colorScheme.inversePrimary,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              elevation: 7.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
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
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          kitchenName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onTertiaryContainer,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
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
