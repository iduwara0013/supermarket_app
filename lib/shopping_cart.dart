import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Pickup_Details.dart'; // Import the Pickup Details page

class ShoppingCartPage extends StatelessWidget {
  final double discount = 0.0;
  final double deliveryCharge = 120.00;

  ShoppingCartPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 58, 104, 16),
        title: Text('Shopping Cart'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('current_user').doc('current').snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return Center(child: Text('Error retrieving user: ${userSnapshot.error}'));
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Center(child: CircularProgressIndicator());
          }

          var currentUserData = userSnapshot.data!.data() as Map<String, dynamic>;
          String userId = currentUserData['userId'];

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('cart').doc(userId).snapshots(),
            builder: (context, cartSnapshot) {
              if (cartSnapshot.hasError) {
                return Center(child: Text('Error: ${cartSnapshot.error}'));
              }

              if (!cartSnapshot.hasData || !cartSnapshot.data!.exists) {
                return Center(child: Text('Your cart is empty.'));
              }

              var cartData = cartSnapshot.data!.data() as Map<String, dynamic>? ?? {};
              // Check if 'items' is a map or list
              var itemsData = cartData['items'];
              List<dynamic> cartItems = [];

              if (itemsData is Map<String, dynamic>) {
                cartItems = itemsData.values.toList();
              } else if (itemsData is List) {
                cartItems = itemsData;
              }

              num subTotal = cartData['totalPrice'] ?? 0;
              double total = subTotal.toDouble() - discount + deliveryCharge;

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        var item = cartItems[index] as Map<String, dynamic>;
                        return cartItem(
                          itemName: item['name'] ?? 'Unknown',
                          itemCategory: item['category'] ?? 'Unknown',
                          price: (item['price'] as num?)?.toDouble() ?? 0.0,
                          itemCount: item['quantity'] ?? 0,
                          totalPrice: (item['totalPrice'] as num?)?.toDouble() ?? 0.0,
                          userId: userId,
                          itemIndex: index,
                          itemData: item, // Pass the entire item data for removal
                        );
                      },
                    ),
                  ),
                  summarySection(subTotal.toDouble(), total),
                  checkoutButtons(context, userId),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget cartItem({
    required String itemName,
    required String itemCategory,
    required double price,
    required int itemCount,
    required double totalPrice,
    required String userId,
    required int itemIndex,
    required Map<String, dynamic> itemData, // New parameter
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
                  color: Colors.green,
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
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        itemCategory,
                        style: TextStyle(
                          color: Colors.grey,
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
                      Text(
                        'Total: Rs $totalPrice',
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
                    updateCartItemQuantity(userId, itemIndex, itemCount - 1);
                  } else {
                    removeCartItem(userId, itemData); // Pass itemData directly
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.black),
                onPressed: () {
                  removeCartItem(userId, itemData); // Pass itemData directly
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PickupDetailsScreen( ),
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
      'items.$itemIndex.quantity': newQuantity,
    });
  }

  void removeCartItem(String userId, Map<String, dynamic> itemData) {
    FirebaseFirestore.instance.collection('cart').doc(userId).update({
      'items': FieldValue.arrayRemove([itemData]), // Remove the item using its data
    });
  }
}
