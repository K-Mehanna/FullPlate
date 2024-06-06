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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
      ),
      body: ListView.builder(
        itemCount: completedJobs.length,
        itemBuilder: (context, index) {
          final job = completedJobs[index];
          final kitchenName = kitchensInfo[job.kitchenId]?.name ?? "--";
          return Card(
            elevation: 2.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              title: Text(kitchenName),
              subtitle: Text("x${job.quantity} ${job.timeCompleted}"),
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
