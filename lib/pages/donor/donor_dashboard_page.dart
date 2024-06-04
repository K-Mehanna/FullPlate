import 'package:cibu/database/kitchens_manager.dart';
import 'package:cibu/models/kitchen_info.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/models/offer_info.dart';
import 'package:cibu/widgets/request_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cibu/pages/donor/new_request_page.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DonorDashboard extends StatefulWidget {
  DonorDashboard({Key? key}) : super(key: key);

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final OrdersManager ordersManager = OrdersManager();
  Map<String, KitchenInfo> kitchensInfo = {};
  List<JobInfo> acceptedJobs = [];
  List<OfferInfo> pendingOffers = [];

  final String donorId = "sec0ABRO6ReQz1hxiKfJ";

  @override
  void initState() {
    super.initState();

    ordersManager
      .setOpenOffersListener(donorId, (newPending) {
        setState(() {
          pendingOffers.clear();
          pendingOffers.addAll(newPending);
        });
      });

    ordersManager
      .setJobsListener(OrderStatus.ACCEPTED, donorId, null, (newAccepted) {
        processKitchenInfo(newAccepted);
        setState(() {
          acceptedJobs.clear();
          acceptedJobs.addAll(newAccepted);
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
                      _buildSectionTitle("Waiting for pickup", acceptedJobs.length),
                      ...acceptedJobs.map(buildJobItem)
                    ]
                  ),
                  SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Unassigned", pendingOffers.length),
                      ...pendingOffers.map(buildOfferItem)
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

  void processKitchenInfo(List<JobInfo> orders) {
    for (var order in orders) {
      assert(order.status == OrderStatus.ACCEPTED);

      KitchensManager()
        .getKitchenCompletion(order.kitchenId, (kitchen) {
          setState(() {
            kitchensInfo[order.kitchenId] = kitchen;
          });
        });    
    }
  }

  Widget buildJobItem(JobInfo job) {    
    return ListTile(
      leading: Icon(Icons.person),
      title: Text(kitchensInfo[job.kitchenId]?.name ?? "..."),
      trailing: Text("x${job.quantity}"),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetailPage(job: job),
          ),
        );
      },
    );
  }
  
  Widget buildOfferItem(OfferInfo offer) {
    return ListTile(
      leading: offer.category.icon,
      title: Text(offer.name),
      trailing: Text("x${offer.quantity}")
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Text("$title ($count)",
        style: TextStyle(fontWeight: FontWeight.bold));
  }
}
