import 'package:cibu/pages/kitchen/donor_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cibu/widgets/build_list_item.dart';
import 'package:cibu/models/request_item.dart';

class KitchenDashboardPage extends StatefulWidget {
  KitchenDashboardPage({super.key});

  @override
  KitchenDashboardPageState createState() => KitchenDashboardPageState();
}

class KitchenDashboardPageState extends State<KitchenDashboardPage> {
  final List<RequestItem> activeJobs = [
    RequestItem(
      title: "avocado",
      location: "Kitchen X",
      address: "1 Holborn Close, E3 8AB",
      quantity: 15,
      size: "M",
      category: "Veg",
      claimed: true,
    ),
    RequestItem(
      title: "banana",
      location: "Kitchen X",
      address: "1 Holborn Close, E3 8AB",
      quantity: 10,
      size: "L",
      category: "Fruit",
      claimed: true,
    ),
    RequestItem(
      title: "carrot",
      location: "Kitchen Y",
      address: "2 Holborn Close, E3 8AC",
      quantity: 20,
      size: "S",
      category: "Veg",
      claimed: true,
    ),
  ];

  final List<RequestItem> pending = [
    RequestItem(
      title: "avocado",
      location: "",
      address: "",
      quantity: 0,
      size: "N/A",
      category: "Veg",
      claimed: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildSectionTitle("Active Jobs", activeJobs.length),
                  ...activeJobs
                      .map((item) => buildListItem(
                          context, item, (item) => DonorDetailPage(item: item)))
                      .toList(),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Text("$title ($count)",
        style: TextStyle(fontWeight: FontWeight.bold));
  }
}
