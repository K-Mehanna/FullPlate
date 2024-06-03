import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/order_info.dart';
import 'package:flutter/material.dart';
import 'package:cibu/widgets/request_detail_page.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/database/donors_manager.dart';

class KitchenDashboardPage extends StatefulWidget {
  KitchenDashboardPage({super.key});

  @override
  KitchenDashboardPageState createState() => KitchenDashboardPageState();
}

class KitchenDashboardPageState extends State<KitchenDashboardPage> {
  final OrdersManager ordersManager = OrdersManager();

  Map<String, DonorInfo> donorsInfo = {};
  List<OrderInfo> acceptedOrders = [];

  final String kitchenId = "BgOtpuMuOZNa6IYWRJgb";

  @override
  void initState() {
    super.initState();

    ordersManager
      .setOrderListener(OrderStatus.ACCEPTED, false, null, kitchenId, (newAccepted) {
        processDonorsInfo(newAccepted);
        setState(() {
          acceptedOrders.clear();
          acceptedOrders.addAll(newAccepted);
        });
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Active Jobs", acceptedOrders.length),
                      ...acceptedOrders.map(buildListItem)
                    ]
                  )
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  void processDonorsInfo(List<OrderInfo> orders) {
    for (var order in orders) {
      assert(order.status == OrderStatus.ACCEPTED);

      DonorsManager()
        .getDonorCompletion(order.donorId, (donor) {
          setState(() {
            donorsInfo[order.donorId] = donor;
          });
        });
    }
  }

  Widget buildListItem(OrderInfo order) {
    var content = order.status == OrderStatus.ACCEPTED ? "..." : "";
    return ListTile(
      leading: Icon(Icons.person),
      title: Text(order.name),
      trailing: Text(donorsInfo[order.donorId]?.name ?? content),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetailPage(item: order),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Text("$title ($count)",
        style: TextStyle(fontWeight: FontWeight.bold));
  }
}