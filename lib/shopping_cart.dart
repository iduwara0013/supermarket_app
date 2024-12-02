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
        backgroundColor: Colors.green,
        title: Text(
          'Shopping Cart',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('current_user').doc('current').snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return Center(child: Text('Error: ${userSnapshot.error}'));
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
              var itemsData = cartData['items'];
              List<dynamic> cartItems = [];

              if (itemsData is Map<String, dynamic>) {
                cartItems = itemsData.values.toList();
              } else if (itemsData is List) {
                cartItems = itemsData;
              }

              num subTotal = cartData['totalPrice'] ?? 0; // Fetch subtotal from Firestore
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
    required Map<String, dynamic> itemData,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.shopping_cart, color: Colors.green, size: 32),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    itemCategory,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rs $price',
                    style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$itemCount Item(s)',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => removeCartItem(userId, itemData),
            ),
          ],
        ),
      ),
    );
  }

  Widget summarySection(double subTotal, double total) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.green[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          summaryRow('Sub Total', 'Rs $subTotal'),
          summaryRow('Discount', 'Rs $discount'),
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
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget checkoutButtons(BuildContext context, String userId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PickupDetailsScreen()),
                );
              },
              child: Text(
                'CHECKOUT',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void removeCartItem(String userId, Map<String, dynamic> itemData) {
    double price = (itemData['price'] as num?)?.toDouble() ?? 0.0;
    int quantity = itemData['quantity'] ?? 1;
    double itemTotal = price * quantity;

    FirebaseFirestore.instance.collection('cart').doc(userId).update({
      'items': FieldValue.arrayRemove([itemData]),
      'totalPrice': FieldValue.increment(-itemTotal),
    }).then((_) {
      FirebaseFirestore.instance.collection('beverages').doc(itemData['id']).update({
        'stock': FieldValue.increment(quantity),
      });
    });
  }
}
