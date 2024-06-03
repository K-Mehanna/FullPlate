import 'package:cibu/database/kitchens_manager.dart';
import 'package:cibu/models/kitchen_info.dart';
import 'package:cibu/models/order_info.dart';
import 'package:cibu/widgets/request_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cibu/pages/donor/new_request_page.dart';
import 'package:cibu/database/orders_manager.dart';

class DonorDashboard extends StatefulWidget {
  DonorDashboard({Key? key}) : super(key: key);

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final OrdersManager ordersManager = OrdersManager();
  Map<String, KitchenInfo> kitchensInfo = {};
  List<OrderInfo> acceptedOrders = [];
  List<OrderInfo> pendingOrders = [];

  final String donorId = "sec0ABRO6ReQz1hxiKfJ";

  @override
  void initState() {
    super.initState();

    ordersManager
      .setOrderListener(OrderStatus.ACCEPTED, false, donorId, null, (newAccepted) {
        processKitchenInfo(newAccepted);
        setState(() {
          acceptedOrders.clear();
          acceptedOrders.addAll(newAccepted);
        });
      });

    ordersManager
      .setOrderListener(OrderStatus.PENDING, false, donorId, null, (newPending) {
        setState(() {
          pendingOrders.clear();
          pendingOrders.addAll(newPending);
        });
      });
  }

  void _addNewRequest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewRequestPage(),
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
        onPressed: () => _addNewRequest(),
        label: Text("Add a new order"),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Accepted Jobs", acceptedOrders.length),
                      ...acceptedOrders.map(buildListItem)
                    ]
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Pending Jobs", pendingOrders.length),
                      ...pendingOrders.map(buildListItem)
                    ]
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void processKitchenInfo(List<OrderInfo> orders) {
    for (var order in orders) {
      assert(order.status == OrderStatus.ACCEPTED);

      KitchensManager()
        .getKitchenCompletion(order.kitchenId!, (kitchen) {
          setState(() {
            kitchensInfo[order.kitchenId!] = kitchen;
          });
        });    
    }
  }

  Widget buildListItem(OrderInfo order) {
    var content = order.status == OrderStatus.ACCEPTED ? "..." : "";
    return ListTile(
      leading: Icon(Icons.person),
      title: Text(order.name),
      trailing: Text(kitchensInfo[order.kitchenId]?.name ?? content),
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
