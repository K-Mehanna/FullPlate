import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/order_info.dart';
import 'package:flutter/material.dart';

class NewRequestPage extends StatefulWidget {
  const NewRequestPage({super.key});

  @override
  NewRequestPageState createState() => NewRequestPageState();
}

class NewRequestPageState extends State<NewRequestPage> {
  final OrdersManager ordersManager = OrdersManager();
  final TextEditingController titleController = TextEditingController();
  int quantity = 1;
  OrderCategory selectedCategory = OrderCategory.BREAD;
  OrderSize selectedSize = OrderSize.MEDIUM;

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
    final newItem = OrderInfo(
      name: titleController.text,
      quantity: quantity,
      category: selectedCategory,
      size: selectedSize,
      timeCreated: DateTime.now(),
      donorId: "sec0ABRO6ReQz1hxiKfJ",
      status: OrderStatus.PENDING,
    );
    ordersManager.addPendingOrder(newItem, null);
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
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            SizedBox(height: 16),
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
            Text("Size"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: OrderSize.values.map((size) {
                return ChoiceChip(
                  label: Text(size.value),
                  selected: selectedSize == size,
                  onSelected: (selected) {
                    setState(() {
                      selectedSize = size;
                    });
                  },
                );
              }).toList(),
            ),
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
