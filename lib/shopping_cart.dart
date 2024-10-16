import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Pickup_Details.dart'; // Import the Pickup Details page

class ShoppingCartPage extends StatelessWidget {
  final double discount = 0.0;
  final double deliveryCharge = 120.00;

  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in and retrieve their document ID
    String? userId = currentUser?.uid;
    if (userId == null) {
      // User is not logged in, show empty cart message
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text('Shopping Cart'),
        ),
        body: Center(child: Text('Your cart is empty. Please log in to add items.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Shopping Cart'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('cart').doc('16').snapshots(), // Use the user's UID dynamically
        builder: (context, snapshot) {
          // Error handling
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Show loading indicator while fetching data
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Check if the cart is empty or doesn't exist
          if (!snapshot.data!.exists) {
            return Center(child: Text('Your cart is empty.'));
          }

          // Get cart data
          var data = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> cartItems = data['items'] ?? [];
          num subTotal = data['total'] ?? 0; // Handle both int and double
          double total = subTotal.toDouble() - discount + deliveryCharge;

          // Display cart items
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
                      price: (item['price'] as num).toDouble(), // Ensure price is treated as double
                      itemCount: item['quantity'],
                      available: true, // Assuming all items are available for now
                      userId: userId,
                      itemIndex: index,
                    );
                  },
                ),
              ),
              summarySection(subTotal.toDouble(), total),
              checkoutButtons(context, userId),
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
    required String userId,
    required int itemIndex,
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
                  updateCartItemQuantity(userId, itemIndex, itemCount + 1);
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
                  if (itemCount > 1) {
                    // Handle item decrease
                    updateCartItemQuantity(userId, itemIndex, itemCount - 1);
                  } else {
                    // Remove item if quantity is 1
                    removeCartItem(userId, itemIndex);
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.black),
                onPressed: () {
                  // Handle item removal
                  removeCartItem(userId, itemIndex);
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

  Widget checkoutButtons(BuildContext context, String userId) {
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
                // Handle cancel action
                Navigator.pop(context); // Go back to the previous screen
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
                    builder: (context) => PickupDetailsScreen(userId: userId, docId: '',), // Pass the user ID correctly
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

  void updateCartItemQuantity(String userId, int itemIndex, int newQuantity) {
    FirebaseFirestore.instance.collection('cart').doc(userId).update({
      'items.$itemIndex.quantity': newQuantity, // Update the specific item's quantity
    });
  }

  void removeCartItem(String userId, int itemIndex) {
    FirebaseFirestore.instance.collection('cart').doc(userId).update({
      'items': FieldValue.arrayRemove([{
        'name': 'item_name_here', // Replace with the actual item name
        'quantity': 1, // Replace with the actual item quantity
        'price': 'item_price_here' // Replace with the actual item price
      }]), // Remove item from array
    });
  }
}
