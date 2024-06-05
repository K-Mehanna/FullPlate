import 'package:cibu/models/kitchen_info.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/widgets/request_detail_page.dart';
import 'package:cibu/database/kitchens_manager.dart';
import 'package:flutter/material.dart';

Widget buildListItem(BuildContext context, JobInfo order) {
  final KitchensManager manager = KitchensManager();
  KitchenInfo? kitchenInfo;

  void getKitchenInfo(JobInfo order) async {
    // kitchenInfo = await manager.getKitchen(order.kitchenId!);
    kitchenInfo = await manager.getKitchen(order.kitchenId);
  }

  // if (order.kitchenId != null) getKitchenInfo(order);
  getKitchenInfo(order);
  return ListTile(
    leading: Icon(Icons.person),
    title: Text(order.jobId),
    trailing: Text(kitchenInfo?.name ?? ""),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RequestDetailPage(job: order),
        ),
      );
    },
  );
}

// class ListItemWidget extends StatelessWidget {
//   final OrderInfo order;

//   const ListItemWidget({Key? key, required this.order}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<String>(
//       future: KitchensManager().getKitchen(order.kitchenId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return ListTile(
//             leading: Icon(Icons.person),
//             title: Text(order.name),
//             trailing: Text("Loading..."),
//           );
//         } else if (snapshot.hasError) {
//           return ListTile(
//             leading: Icon(Icons.person),
//             title: Text(order.name),
//             trailing: Text("Error"),
//           );
//         } else {
//           return ListTile(
//             leading: Icon(Icons.person),
//             title: Text(order.name),
//             trailing: Text(snapshot.data ?? ""),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => RequestDetailPage(item: order),
//                 ),
//               );
//             },
//           );
//         }
//       },
//     );
//   }
// }























// /////////////////////// kareem no



// class ListItemWidget extends StatelessWidget {
//   final OrderInfo order;

//   const ListItemWidget({Key? key, required this.order}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return 
//     FutureBuilder<String>(
//       future: KitchensManager().getKitchen(order.kitchenId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return ListTile(
//             leading: Icon(Icons.person),
//             title: Text(order.name),
//             trailing: Text("Loading..."),
//           );
//         } else if (snapshot.hasError) {
//           return ListTile(
//             leading: Icon(Icons.person),
//             title: Text(order.name),
//             trailing: Text("Error"),
//           );
//         } else {
//           return ListTile(
//             leading: Icon(Icons.person),
//             title: Text(order.name),
//             trailing: Text(snapshot.data ?? ""),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => RequestDetailPage(item: order),
//                 ),
//               );
//             },
//           );
//         }
//       },
//     );
//   }
// }