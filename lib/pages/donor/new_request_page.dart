import 'package:flutter/material.dart';
import 'package:cibu/models/request_item.dart';

class NewRequestPage extends StatefulWidget {
  final Function(RequestItem) addRequestCallback;

  const NewRequestPage({required this.addRequestCallback, Key? key})
      : super(key: key);

  @override
  NewRequestPageState createState() => NewRequestPageState();
}

class NewRequestPageState extends State<NewRequestPage> {
  final TextEditingController titleController = TextEditingController();
  final List<String> categories = ["Egg", "Bread", "Milk", "Cheese", "Butter"];
  String selectedCategory = "Egg";
  int quantity = 1;
  String selectedSize = "M";

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
    final newItem = RequestItem(
      title: titleController.text,
      location: "",
      address: "",
      quantity: quantity,
      size: selectedSize,
      category: selectedCategory,
      claimed: false,
    );
    widget.addRequestCallback(newItem);
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
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
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
              children: ["S", "M", "L"].map((size) {
                return ChoiceChip(
                  label: Text(size),
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
