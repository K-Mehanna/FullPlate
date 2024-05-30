import 'package:flutter/material.dart';
import 'package:cibu/models/request_item.dart';

class DonorDetailPage extends StatelessWidget {
  final RequestItem item;

  DonorDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Viewing Request"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Donor name", "M&S Holborn"),
            SizedBox(height: 16),
            _buildDetailRow("Donor location",
                "323-324 High Holborn,\nSpringfield Way,\nLondon\nWC1V 7PD"),
            SizedBox(height: 16),
            _buildDetailRow("Title", "\"${item.title}\""),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn("Quantity", item.quantity.toString()),
                _buildDetailColumn("Category", item.category),
                _buildDetailColumn("Size", item.size),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool withIcon = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        if (withIcon)
          Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 8),
              Text(value),
            ],
          )
        else
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
