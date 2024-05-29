import 'package:flutter/material.dart';
import 'request_detail_page.dart';
import 'new_request_page.dart';

class RequestItem {
  final String title;
  final String location;
  final String address;
  final int quantity;
  final String size;
  final String status;

  RequestItem({
    required this.title,
    required this.location,
    required this.address,
    required this.quantity,
    required this.size,
    required this.status,
  });
}

class DonorHomePage extends StatefulWidget {
  DonorHomePage({super.key});

  @override
  DonorHomePageState createState() => DonorHomePageState();
}

class DonorHomePageState extends State<DonorHomePage> {
  final List<RequestItem> waitingToLoad = [
    RequestItem(
      title: "avocado",
      location: "Kitchen X",
      address: "1 Holborn Close, E3 8AB",
      quantity: 15,
      size: "M",
      status: "",
    ),
    RequestItem(
      title: "banana",
      location: "Kitchen X",
      address: "1 Holborn Close, E3 8AB",
      quantity: 10,
      size: "L",
      status: "",
    ),
    RequestItem(
      title: "carrot",
      location: "Kitchen Y",
      address: "2 Holborn Close, E3 8AC",
      quantity: 20,
      size: "S",
      status: "",
    ),
  ];

  final List<RequestItem> pending = [
    RequestItem(
      title: "avocado",
      location: "",
      address: "",
      quantity: 0,
      size: "N/A",
      status: "Waiting to be claimed",
    ),
  ];

  void addNewRequest(RequestItem item) {
    setState(() {
      pending.add(item);
    });
  }

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
                  _buildSectionTitle("Waiting to load", waitingToLoad.length),
                  ...waitingToLoad.map((item) => _buildListItem(context, item)).toList(),
                  SizedBox(height: 16),
                  _buildSectionTitle("Pending", pending.length),
                  ...pending.map((item) => _buildListItem(context, item)).toList(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewRequestPage(
                        addRequestCallback: addNewRequest,
                      ),
                    ),
                  );
                },
                child: Icon(Icons.add),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        onTap: (index) {},
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Text("$title ($count)", style: TextStyle(fontWeight: FontWeight.bold));
  }

  Widget _buildListItem(BuildContext context, RequestItem item) {
    return ListTile(
      leading: Icon(Icons.person),
      title: Text("\"${item.title}\""),
      trailing: Text(item.location.isEmpty ? item.status : item.location),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetailPage(item: item),
          ),
        );
      },
    );
  }
}

