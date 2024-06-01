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
  bool didGetKitchenInfo = false;

  Future<List<OrderInfo>> _getPendingOrders() {
    return ordersManager.getOrders(
        OrderStatus.PENDING, false, "sec0ABRO6ReQz1hxiKfJ", null);
  }

  Future<List<OrderInfo>> _getAcceptedOrders() {
    return ordersManager.getOrders(
        OrderStatus.ACCEPTED, false, 'sec0ABRO6ReQz1hxiKfJ', null);
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
                  FutureBuilder<List<OrderInfo>>(
                    future: _getAcceptedOrders(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        processKitchenInfo(snapshot.data ?? []);
                        final acceptedOrders = snapshot.data ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(
                                "Accepted", acceptedOrders.length),
                            ...acceptedOrders
                                .map((item) => buildListItem(item))
                                .toList(),
                            SizedBox(height: 16),
                          ],
                        );
                      }
                    },
                  ),
                  FutureBuilder<List<OrderInfo>>(
                    future: _getPendingOrders(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        final pendingOrders = snapshot.data ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Pending", pendingOrders.length),
                            ...pendingOrders
                                .map((item) => buildListItem(item))
                                .toList(),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void processKitchenInfo(List<OrderInfo> orders) {
    if (didGetKitchenInfo) return;
    didGetKitchenInfo = true;
    for (var order in orders) {
      if (order.status != OrderStatus.ACCEPTED) continue;

      void makeListTile(KitchenInfo kitchenInfo) {
        setState(() {
          print("Kitchen name: ${kitchenInfo.name}");
          kitchensInfo[order.kitchenId!] = kitchenInfo;
        });
      }

      KitchensManager().getKitchenCompletion(
          order.kitchenId!, (kitchen) => makeListTile(kitchen));
    }
  }

  Widget buildListItem(OrderInfo order) {
    return ListTile(
      leading: Icon(Icons.person),
      title: Text(order.name),
      trailing: Text(kitchensInfo[order.kitchenId]?.name ?? ""),
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
