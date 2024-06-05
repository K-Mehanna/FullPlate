import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/offer_info.dart';
import 'package:flutter/material.dart';

class NewRequestPage extends StatefulWidget {
  const NewRequestPage({super.key});

  @override
  NewRequestPageState createState() => NewRequestPageState();
}

class NewRequestPageState extends State<NewRequestPage> {
  final OrdersManager ordersManager = OrdersManager();
  int quantity = 1;
  OrderCategory selectedCategory = OrderCategory.BREAD;

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  void submitRequest() {
    final newItem = OfferInfo(quantity: quantity, category: selectedCategory);
    ordersManager.addOpenOffer("sec0ABRO6ReQz1hxiKfJ", newItem);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<OrderCategory>(
              value: selectedCategory,
              items: OrderCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              decoration: InputDecoration(labelText: "Category"),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Quantity"),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: decrementQuantity,
                    ),
                    Text(quantity.toString()),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: incrementQuantity,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton.icon(
                onPressed: submitRequest,
                icon: Icon(Icons.check),
                label: Text("Done"),
                style: ElevatedButton.styleFrom(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
