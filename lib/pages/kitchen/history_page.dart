import 'package:flutter/material.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/pages/kitchen/job_detail_page.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  final List<JobInfo> completedJobs;
  final Map<String, DonorInfo> donorsInfo;

  const HistoryPage({
    Key? key,
    required this.completedJobs,
    required this.donorsInfo,
  }) : super(key: key);

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
          itemCount: completedJobs.length,
          itemBuilder: (context, index) {
            final job = completedJobs[index];
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
                      donorsInfo[job.donorId]?.name ?? "--",
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
                        Icon(Icons.production_quantity_limits,
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
