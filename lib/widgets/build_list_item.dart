import 'package:flutter/material.dart';
import 'package:cibu/models/request_item.dart';

Widget buildListItem(BuildContext context, RequestItem item, Widget Function(RequestItem) builder) {
    return ListTile(
      leading: Icon(Icons.person),
      title: Text("\"${item.title}\""),
      trailing: Text(item.location.isEmpty ? item.claimed.toString() : item.location),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => builder(item),
          ),
        );
      },
    );
  }