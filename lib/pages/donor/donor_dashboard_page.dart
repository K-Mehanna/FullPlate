import 'package:cibu/widgets/request_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cibu/pages/donor/new_request_page.dart';
import 'package:cibu/widgets/build_list_item.dart';
import 'package:cibu/models/request_item.dart';

class DonorDashboard extends StatefulWidget {
  DonorDashboard({super.key});

  @override
  DonorDashboardState createState() => DonorDashboardState();
}

class DonorDashboardState extends State<DonorDashboard> {
  final List<RequestItem> waitingToLoad = [
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

  void _addNewRequest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewRequestPage(
          addRequestCallback: (RequestItem item) => {
            setState(() {
              pending.add(item);
            })
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewRequest,
        label: Text("Add a new item"),
        icon: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildSectionTitle("Waiting to load", waitingToLoad.length),
                  ...waitingToLoad
                      .map(
                        (item) => buildListItem(
                          context,
                          item,
                          (item) => RequestDetailPage(item: item),
                        ),
                      )
                      .toList(),
                  SizedBox(height: 16),
                  _buildSectionTitle("Pending", pending.length),
                  ...pending
                      .map(
                        (item) => buildListItem(
                          context,
                          item,
                          (item) => RequestDetailPage(item: item),
                        ),
                      )
                      .toList(),
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
