import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/order_info.dart';
import 'package:flutter/material.dart';
//import 'package:cibu/pages/kitchen/build_list_item.dart';
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
  List<OrderInfo>? acceptedOrders;
  Map<String, DonorInfo> donorsInfo = {};
  bool didGetDonorsInfo = false;

  Future<List<OrderInfo>> _getAcceptedOrders() {
    return ordersManager.getOrders(
        OrderStatus.ACCEPTED, false, 'sec0ABRO6ReQz1hxiKfJ', null);
  }

  @override
  void initState() {
    super.initState();

    ordersManager
        .getOrders(OrderStatus.PENDING, false, 'znR7gs5otoK7r6BtP6zl', null)
        .then((value) {
      setState(() {
        acceptedOrders = value;
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
                  FutureBuilder(
                    future: _getAcceptedOrders(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        processDonorsInfo(snapshot.data ?? []);
                        final acceptedOrders = snapshot.data ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(
                                "Active Jobs", acceptedOrders.length),
                            ...acceptedOrders
                                .map((item) => buildListItem(item))
                                .toList(),
                            SizedBox(height: 16),
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

  void processDonorsInfo(List<OrderInfo> orders) {
    if (didGetDonorsInfo) return;
    didGetDonorsInfo = true;
    for (var order in orders) {
      void makeListTile(DonorInfo donorInfo) {
        setState(() {
          print("Donor name: ${donorInfo.name}");
          donorsInfo[order.donorId] = donorInfo;
        });
      }

      DonorsManager()
          .getDonorCompletion(order.donorId, (donor) => makeListTile(donor));
    }
  }

  Widget buildListItem(OrderInfo order) {
    return ListTile(
      leading: Icon(Icons.person),
      title: Text(order.name),
      trailing: Text(donorsInfo[order.donorId]?.name ?? "..."),
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







//////////////////////////////////////////////////// skibidi toilet

// class DonorDashboard extends StatefulWidget {
//   DonorDashboard({super.key});

//   @override
//   DonorDashboardState createState() => DonorDashboardState();
// }

// class DonorDashboardState extends State<DonorDashboard> {
//   final OrdersManager ordersManager = OrdersManager();

//   List<OrderInfo>? acceptedOrders;
//   List<OrderInfo>? pendingOrders;

//   @override
//   void initState() {
//     super.initState();

//     ordersManager.getOrders(OrderStatus.PENDING, false, 'znR7gs5otoK7r6BtP6zl', null).then((value) {
//       setState(() {
//         acceptedOrders = value;
//       });
//     });

//     ordersManager.getOrders(OrderStatus.ACCEPTED, false, 'znR7gs5otoK7r6BtP6zl', null).then((value) {
//       setState(() {
//         pendingOrders = value;
//       });
//     });
//   }

//   void _addNewRequest() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => NewRequestPage(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Dashboard"),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _addNewRequest,
//         label: Text("Add a new order"),
//         icon: Icon(Icons.add),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildSectionTitle("Waiting to load", acceptedOrders!.length),
//                   ...acceptedOrders!
//                       .map(
//                         (item) => buildListItem(
//                           context,
//                           item,
//                         ),
//                       )
//                       .toList(),
//                   SizedBox(height: 16),
//                   _buildSectionTitle("Pending", pendingOrders!.length),
//                   ...pendingOrders!
//                       .map(
//                         (item) => buildListItem(
//                           context,
//                           item,
//                         ),
//                       )
//                       .toList(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title, int count) {
//     return Text("$title ($count)",
//         style: TextStyle(fontWeight: FontWeight.bold));
//   }
// }