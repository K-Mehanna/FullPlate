// import 'package:cibu/database/orders_manager.dart';
// import 'package:cibu/models/offer_info.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class NewRequestPage extends StatefulWidget {
//   const NewRequestPage({super.key});

//   @override
//   NewRequestPageState createState() => NewRequestPageState();
// }

// class NewRequestPageState extends State<NewRequestPage> {
//   final OrdersManager ordersManager = OrdersManager();
//   final ValueNotifier<int> quantityNotifier = ValueNotifier<int>(1);

//   OrderCategory selectedCategory = OrderCategory.BREAD;
//   final TextEditingController quantityController =
//       TextEditingController(text: '1');

//   @override
//   void dispose() {
//     quantityNotifier.dispose();
//     quantityController.dispose();
//     super.dispose();
//   }

//   void incrementQuantity() {
//     quantityNotifier.value++;
//     quantityController.text = quantityNotifier.value.toString();
//   }

//   void decrementQuantity() {
//     if (quantityNotifier.value > 1) {
//       quantityNotifier.value--;
//       quantityController.text = quantityNotifier.value.toString();
//     }
//   }

//   void submitRequest() {
//     final newItem =
//         OfferInfo(quantity: quantityNotifier.value, category: selectedCategory);
//     ordersManager.addOpenOffer(FirebaseAuth.instance.currentUser!.uid,
//         newItem); //"sec0ABRO6ReQz1hxiKfJ"
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Add new item"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             DropdownButtonFormField<OrderCategory>(
//               value: selectedCategory,
//               items: OrderCategory.values.map((category) {
//                 return DropdownMenuItem(
//                   value: category,
//                   child: Text(category.value),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedCategory = value!;
//                 });
//               },
//               decoration: InputDecoration(labelText: "Category"),
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Quantity"),
//                 Row(
//                   children: [
//                     ValueListenableBuilder<int>(
//                       valueListenable: quantityNotifier,
//                       builder: (context, value, _) {
//                         return IconButton(
//                           icon: Icon(Icons.remove),
//                           onPressed: (value > 1) ? decrementQuantity : null,
//                         );
//                       },
//                     ),
//                     SizedBox(
//                       width: 25,
//                       child: TextField(
//                         controller: quantityController,
//                         keyboardType: TextInputType.number,
//                         inputFormatters: <TextInputFormatter>[
//                           FilteringTextInputFormatter.digitsOnly
//                         ],
//                         onChanged: (value) {
//                           int? intValue = int.tryParse(value);
//                           if (intValue != null &&
//                               intValue >= 1 &&
//                               intValue <= 99) {
//                             quantityNotifier.value = intValue;
//                           } else if (intValue != null && intValue > 99) {
//                             quantityNotifier.value = 99;
//                             quantityController.text = "99";
//                           } else {
//                             quantityController.text =
//                                 quantityNotifier.value.toString();
//                           }
//                         },
//                       ),
//                     ),
//                     ValueListenableBuilder<int>(
//                       valueListenable: quantityNotifier,
//                       builder: (context, value, _) {
//                         return IconButton(
//                           icon: Icon(Icons.add),
//                           onPressed: (value < 99) ? incrementQuantity : null,
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Spacer(),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: ElevatedButton.icon(
//                 onPressed: submitRequest,
//                 icon: Icon(Icons.check),
//                 label: Text("Done"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
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
    if (index != 0) {
      setState(() {
        orders[index].dispose();
        orders.removeAt(index);
      });
    }
  }

  OrderCategory getFirstAvailableCategory() {
    for (var category in OrderCategory.values) {
      if (!categoryAlreadySelected(category)) {
        return category;
      }
    }
    return OrderCategory.BREAD; // Fallback in case all categories are selected
  }

  bool categoryAlreadySelected(OrderCategory category) {
    for (var order in orders) {
      if (order.selectedCategory == category) {
        return true;
      }
    }
    return false;
  }

  bool isCategoryAvailable() {
    return OrderCategory.values
        .any((category) => !categoryAlreadySelected(category));
  }

  void submitRequest() {
    List<OfferInfo> offers = [];
    for (var order in orders) {
      final newItem = OfferInfo(
          quantity: order.quantityNotifier.value,
          category: order.selectedCategory);

      if (newItem.quantity > 0) offers.add(newItem);
    }

    // ordersManager.addOpenOffers(FirebaseAuth.instance.currentUser!.uid, offers, () {
    //   Navigator.pop(context);
    // });
    ordersManager.addOpenOffers("HAO9gLWbTaT7z16pBoLGz019iSC3", offers, () {
      Navigator.pop(context);
    });
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
                            items: OrderCategory.values
                                .where((category) =>
                                    !categoryAlreadySelected(category) ||
                                    category == orders[index].selectedCategory)
                                .map((category) {
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
                          if (index != 0)
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => removeOrder(index),
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Quantity"),
                          Row(
                            children: [
                              ValueListenableBuilder<int>(
                                valueListenable: orders[index].quantityNotifier,
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
                                  controller: orders[index].quantityController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onChanged: (value) {
                                    int? intValue = int.tryParse(value);
                                    if (intValue != null &&
                                        intValue >= 1 &&
                                        intValue <= 99) {
                                      orders[index].quantityNotifier.value =
                                          intValue;
                                    } else if (intValue != null &&
                                        intValue > 99) {
                                      orders[index].quantityNotifier.value = 99;
                                      orders[index].quantityController.text =
                                          "99";
                                    } else {
                                      orders[index].quantityController.text =
                                          orders[index]
                                              .quantityNotifier
                                              .value
                                              .toString();
                                    }
                                  },
                                ),
                              ),
                              ValueListenableBuilder<int>(
                                valueListenable: orders[index].quantityNotifier,
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

class OrderItem {
  final ValueNotifier<int> quantityNotifier = ValueNotifier<int>(1);
  OrderCategory selectedCategory;
  final TextEditingController quantityController =
      TextEditingController(text: '1');

  OrderItem({OrderCategory? defaultCategory})
      : selectedCategory = defaultCategory ?? OrderCategory.BREAD;

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
}
