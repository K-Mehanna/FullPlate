import 'package:cibu/database/kitchens_manager.dart';
import 'package:cibu/models/kitchen_info.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/models/offer_info.dart';
import 'package:cibu/pages/donor/job_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  List<JobInfo> acceptedJobs = [];
  List<OfferInfo> pendingOffers = [];

  final _auth = FirebaseAuth.instance;

  late final String donorId;
  //"HAO9gLWbTaT7z16pBoLGz019iSC3"; //FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    donorId = _auth.currentUser!.uid;

    ordersManager.setOpenOffersListener(donorId, (newPending) {
      print(newPending.length);
      if (!mounted) return;
      setState(() {
        pendingOffers.clear();
        pendingOffers.addAll(newPending);
      });
    });

    ordersManager.setJobsListener(OrderStatus.ACCEPTED, donorId, null,
        (newAccepted) {
      processKitchenInfo(newAccepted);
      if (!mounted) return;
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
                        _buildSectionTitle(
                            "Waiting for pickup", acceptedJobs.length),
                        ...acceptedJobs.map(buildJobItem)
                      ]),
                  SizedBox(height: 15),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Unassigned", pendingOffers.length),
                        ...pendingOffers.map(buildOfferItem)
                      ])
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

      KitchensManager().getKitchenCompletion(order.kitchenId, (kitchen) {
        if (!mounted) return;
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
            builder: (context) => JobDetailPage(job: job),
          ),
        );
      },
    );
  }

  Widget buildOfferItem(OfferInfo offer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            offer.category.icon,
            SizedBox(width: 8),
            Text(offer.category.value, style: TextStyle(fontSize: 18)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.hourglass_bottom_rounded),
                Text(
                  offer.getExpiryDescription(),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(width: 10),
            Text(
              "x${offer.quantity}",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 20,
                color: Colors.grey.shade600,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text(
                      "Remove item",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    content: Text(
                      "Are you sure you want to remove this item?",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    actions: [
                      Container(
                        //color: Colors.red,
                        //padding: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.blueGrey.shade50,
                        ),
                        child: TextButton(
                          style: ButtonStyle(
                              padding: WidgetStateProperty.all(
                                  EdgeInsets.symmetric(horizontal: 20))),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Cancel",
                            //style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextButton(
                          onPressed: () {
                            ordersManager.removeOpenOffer(
                                donorId, offer, () {});
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                              padding: WidgetStateProperty.all(
                                  EdgeInsets.symmetric(horizontal: 20))),
                          child: Text(
                            "Remove",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Text("$title ($count)",
        style: TextStyle(fontWeight: FontWeight.bold));
  }
}
