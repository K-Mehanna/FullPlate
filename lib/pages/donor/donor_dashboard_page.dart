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
    // Slidable stuff
    return ListTile(
        leading: offer.category.icon,
        title: Text(offer.category.value),
        trailing: Text("x${offer.quantity}"));
  }

  // Slidable(
  //             // Specify a key if the Slidable is dismissible.
  //             key: const ValueKey(0),

  //             // The start action pane is the one at the left or the top side.
  //             startActionPane: ActionPane(
  //               // A motion is a widget used to control how the pane animates.
  //               motion: const DrawerMotion(),

  //               // A pane can dismiss the Slidable.
  //               dismissible: DismissiblePane(onDismissed: () {}),

  //               // All actions are defined in the children parameter.
  //               children: [
  //                 // A SlidableAction can have an icon and/or a label.
  //                 SlidableAction(
  //                   onPressed: (a) {},
  //                   backgroundColor: Color(0xFFFE4A49),
  //                   foregroundColor: Colors.white,
  //                   icon: Icons.delete,
  //                   label: 'Delete',
  //                 ),
  //               ],
  //             ),

  //             // The end action pane is the one at the right or the bottom side.
  //             endActionPane: ActionPane(
  //               motion: DrawerMotion(),
  //               children: [
  //                 SlidableAction(
  //                   onPressed: (a) {},
  //                   backgroundColor: Color(0xFFFE4A49),
  //                   foregroundColor: Colors.white,
  //                   icon: Icons.delete,
  //                   label: 'Delete',
  //                 ),
  //               ],
  //             ),

  //             // The child of the Slidable is what the user sees when the
  //             // component is not dragged.
  //             child: const ListTile(
  //               title: Text('Slide me'),
  //               tileColor: Colors.grey,
  //             ),
  //           ),

  Widget _buildSectionTitle(String title, int count) {
    return Text("$title ($count)",
        style: TextStyle(fontWeight: FontWeight.bold));
  }
}
