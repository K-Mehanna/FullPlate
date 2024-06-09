import 'package:flutter/material.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/models/kitchen_info.dart';
import 'package:cibu/pages/donor/job_detail_page.dart';

class HistoryPage extends StatelessWidget {
  final List<JobInfo> completedJobs;
  final Map<String, KitchenInfo> kitchensInfo;

  const HistoryPage({
    Key? key,
    required this.completedJobs,
    required this.kitchensInfo,
  }) : super(key: key);

  String getDate(JobInfo job) {
    final time = job.timeCompleted;
    if (time == null) {
      return "--";
    }
    var year = time.year;
    var month = time.month;
    var day = time.day;

    return "$day / $month / $year";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: completedJobs.length,
        itemBuilder: (context, index) {
          final job = completedJobs[index];
          final date = getDate(job);
          final kitchenName = kitchensInfo[job.kitchenId]?.name ?? "--";
          return Card(
            elevation: 2.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              title: Text(kitchenName),
              subtitle: Text("x${job.quantity} $date"),
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
    );
  }
}
