// import 'package:cibu/models/order_info.dart';
// import 'package:cibu/widgets/request_detail_page.dart';
// import 'package:flutter/material.dart';
// import 'package:cibu/models/donor_info.dart';
// import 'package:cibu/database/donors_manager.dart';

// // Widget buildListItem(BuildContext context, OrderInfo order) {
// //   return ListTile(
// //     leading: Icon(Icons.person),
// //     title: Text(order.name),
// //     trailing: Text(getDonor(order.donorId).name),
// //     onTap: () {
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => RequestDetailPage(item: order),
// //         ),
// //       );
// //     },
// //   );
// // }

// Widget buildListItem(BuildContext context, OrderInfo order) {
//   final DonorsManager manager = DonorsManager();

//   Widget donorInfoText = Text("...");

//   DonorInfo? donorInfo;

//   void getDonorInfo(OrderInfo order) async {
//     donorInfo = await manager.getDonor(order.donorId);
//     donorInfoText.
//   }

//   getDonorInfo(order);
//   return ListTile(
//     leading: Icon(Icons.person),
//     title: Text(order.name),
//     trailing: donorInfoText,
//     onTap: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => RequestDetailPage(item: order),
//         ),
//       );
//     },
//   );
// }
