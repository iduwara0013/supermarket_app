import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Pickup_Details.dart';  // Import the Pickup Details page

class ShoppingCartPage extends StatelessWidget {
  final double discount = 0.0;
  final double deliveryCharge = 120.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Shopping Cart'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('cart').doc('13').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> cartItems = data['items'];
          double subTotal = data['total'].toDouble();
          double total = subTotal - discount + deliveryCharge;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index];
                    return cartItem(
                      itemName: item['name'],
                      itemDetails: 'Quantity: ${item['quantity']}',
                      price: item['price'],
                      itemCount: item['quantity'],
                      available: true,  // Assuming all items are available for now
                    );
                  },
                ),
              ),
              summarySection(subTotal, total),
              checkoutButtons(context, '13'), // Pass the document ID here
            ],
          );
        },
      ),
    );
  }

  Widget cartItem({
    required String itemName,
    required String itemDetails,
    required double price,
    required int itemCount,
    required bool available,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: available ? Colors.green : Colors.grey,
                  size: 12,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: available ? Colors.black : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        itemDetails,
                        style: TextStyle(
                          color: available ? Colors.black : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rs $price',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$itemCount Item(s)',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Colors.green),
                onPressed: () {
                  // Handle item increase
                },
              ),
              Text(
                '$itemCount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.green),
                onPressed: () {
                  // Handle item decrease
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.black),
                onPressed: () {
                  // Handle item removal
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget summarySection(double subTotal, double total) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          summaryRow('Sub Total(Rs)', 'Rs $subTotal'),
          summaryRow('Total Discount', 'Rs $discount'),
          summaryRow('Delivery Charge', 'Rs $deliveryCharge'),
          Divider(thickness: 1),
          summaryRow('Total', 'Rs $total', isTotal: true),
        ],
      ),
    );
  }

  Widget summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget checkoutButtons(BuildContext context, String docId) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                // Handle cancel
              },
              child: Text('CANCEL'),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                // Navigate to Pickup Details page on checkout
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PickupDetailsScreen(docId: docId), // Pass the doc ID
                  ),
                );
              },
              child: Text('CHECKOUT'),
            ),
          ),
        ],
      ),
    );
  }
}
