import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/offer_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewRequestPage extends StatefulWidget {
  const NewRequestPage({super.key});

  @override
  NewRequestPageState createState() => NewRequestPageState();
}

class NewRequestPageState extends State<NewRequestPage> {
  final OrdersManager ordersManager = OrdersManager();
  final List<OrderItem> orders = [OrderItem()];
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    for (var order in orders) {
      order.dispose();
    }
    super.dispose();
  }

  void addOrder() {
    setState(() {
      orders.add(OrderItem(defaultCategory: getFirstAvailableCategory()));
    });
  }

  void removeOrder(int index) {
    setState(() {
      orders[index].dispose();
      orders.removeAt(index);
    });
  }

  OrderCategory getFirstAvailableCategory() {
    return OrderCategory.BREAD; // Fallback in case all categories are selected
  }

  bool isCategoryAvailable() {
    return true;
  }

  void submitRequest() {
    List<OfferInfo> offers = [];
    for (var order in orders) {
      final newItem = OfferInfo(
          offerId: "unassigned",
          quantity: order.quantityNotifier.value,
          expiryDate: order.expiryDate,
          category: order.selectedCategory);

      if (newItem.quantity > 0) offers.add(newItem);
    }

    ordersManager.addOpenOffers(_auth.currentUser!.uid, offers, () {
      Navigator.pop(context);
    });
    // ordersManager.addOpenOffers("HAO9gLWbTaT7z16pBoLGz019iSC3", offers, () {
    //   Navigator.pop(context);
    // });
  }

  void _showDatePicker(OrderItem order) {
    showDatePicker(
            context: context,
            initialDate: order.expiryDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 30)))
        .then((date) {
      if (date != null) {
        setState(() {
          order.expiryDate = date;
        });
      }
    });
  }

  Color getButtonColors(Set<WidgetState> state) {
    if (state.contains(WidgetState.hovered)) {
      return Colors.blueGrey.withOpacity(0.9);
    } else if (state.contains(WidgetState.focused) ||
        state.contains(WidgetState.pressed)) {
      return Colors.blueGrey.withOpacity(0.8);
    } else {
      return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new items"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<OrderCategory>(
                            value: orders[index].selectedCategory,
                            items: OrderCategory.values.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                orders[index].selectedCategory = value!;
                              });
                            },
                          ),
                          if (orders.length != 1)
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => removeOrder(index),
                            )
                          else
                            (IconButton(
                              icon: Icon(Icons.close),
                              onPressed: null,
                            ))
                        ],
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Quantity",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    ValueListenableBuilder<int>(
                                      valueListenable:
                                          orders[index].quantityNotifier,
                                      builder: (context, value, _) {
                                        return IconButton(
                                          icon: Icon(Icons.remove),
                                          onPressed: (value > 1)
                                              ? orders[index].decrementQuantity
                                              : null,
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      width: 25,
                                      child: TextField(
                                        controller:
                                            orders[index].quantityController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        onSubmitted: (value) {
                                          int? intValue = int.tryParse(value);
                                          if (intValue != null) {
                                            orders[index]
                                                    .quantityNotifier
                                                    .value =
                                                limitedValue(1, 99, intValue);
                                            orders[index]
                                                    .quantityController
                                                    .text =
                                                limitedValue(1, 99, intValue)
                                                    .toString();
                                          } else {
                                            orders[index]
                                                    .quantityController
                                                    .text =
                                                orders[index]
                                                    .quantityNotifier
                                                    .value
                                                    .toString();
                                          }
                                        },
                                        onChanged: (value) {
                                          int? intValue = int.tryParse(value);
                                          if (intValue != null) {
                                            orders[index]
                                                    .quantityNotifier
                                                    .value =
                                                limitedValue(1, 99, intValue);
                                            orders[index]
                                                    .quantityController
                                                    .text =
                                                limitedValue(1, 99, intValue)
                                                    .toString();
                                          }
                                        },
                                      ),
                                    ),
                                    ValueListenableBuilder<int>(
                                      valueListenable:
                                          orders[index].quantityNotifier,
                                      builder: (context, value, _) {
                                        return IconButton(
                                          icon: Icon(Icons.add),
                                          onPressed: (value < 99)
                                              ? orders[index].incrementQuantity
                                              : null,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Expiry",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(width: 10),
                                TextButton.icon(
                                  icon: Icon(
                                    Icons.hourglass_bottom_rounded,
                                    color: Colors.white,
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateColor.resolveWith(
                                              getButtonColors)),
                                  onPressed: () {
                                    _showDatePicker(orders[index]);
                                  },
                                  label: Text(
                                      overflow: TextOverflow.ellipsis,
                                      orders[index].getExpiryDescription(),
                                      style: TextStyle(color: Colors.white)),
                                )
                              ],
                            ),
                          ]),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: isCategoryAvailable() ? addOrder : null,
              icon: Icon(Icons.add),
              label: Text("Add another item"),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton.icon(
                onPressed: submitRequest,
                icon: Icon(Icons.check),
                label: Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int limitedValue(int lower, int upper, int value) {
  if (value >= lower && value <= upper) {
    return value;
  } else if (value > upper) {
    return upper;
  } else {
    return lower;
  }
}

class OrderItem {
  final ValueNotifier<int> quantityNotifier = ValueNotifier<int>(1);
  OrderCategory selectedCategory;
  DateTime? expiryDate; // = DateTime.now().add(Duration(days: 7));
  final TextEditingController quantityController;

  OrderItem({OrderCategory? defaultCategory})
      : selectedCategory = defaultCategory ?? OrderCategory.BREAD,
        quantityController = TextEditingController(text: '1');

  void incrementQuantity() {
    quantityNotifier.value++;
    quantityController.text = quantityNotifier.value.toString();
  }

  void decrementQuantity() {
    if (quantityNotifier.value > 1) {
      quantityNotifier.value--;
      quantityController.text = quantityNotifier.value.toString();
    }
  }

  void dispose() {
    quantityNotifier.dispose();
    quantityController.dispose();
  }

  String getExpiryDescription() {
    if (expiryDate == null) {
      return "None";
    }
    int days = expiryDate!
        .difference(DateTime.now().subtract(Duration(days: 1)))
        .inDays;

    return "$days day${days > 1 ? "s" : ""}";
  }
}
