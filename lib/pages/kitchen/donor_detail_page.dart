import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/order_info.dart';
import 'package:flutter/material.dart';
import 'package:cibu/models/donor_info.dart';

class DonorDetailPage extends StatelessWidget {
  final OrderInfo order;
  final DonorsManager donorsManager = DonorsManager();
  final OrdersManager ordersManager = OrdersManager();

  DonorDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Viewing Request"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ordersManager.acceptOrder(order, 'BgOtpuMuOZNa6IYWRJgb', null);
          Navigator.pop(context);
        },
        label: Text("Accept order"),
        icon: Icon(
          Icons.check,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DonorInfo>(
          future: donorsManager.getDonor(order.donorId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final donor = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Donor name", donor.name),
                  SizedBox(height: 16),
                  _buildDetailRow("Donor address", donor.address),
                  SizedBox(height: 16),
                  _buildDetailRow("Title", order.name),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailColumn("Quantity", order.quantity.toString()),
                      _buildDetailColumn("Category", order.category.value),
                      _buildDetailColumn("Size", order.size.value),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}
