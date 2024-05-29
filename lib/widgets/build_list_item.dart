import 'package:flutter/material.dart';
import 'request_detail_page.dart';
import 'package:cibu/models/request_item.dart';

Widget buildListItem(BuildContext context, RequestItem item) {
    return ListTile(
      leading: Icon(Icons.person),
      title: Text("\"${item.title}\""),
      trailing: Text(item.location.isEmpty ? item.claimed.toString() : item.location),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetailPage(item: item),
          ),
        );
      },
    );
  }