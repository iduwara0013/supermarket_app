import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'shopping_cart.dart';

class BeverageScreen extends StatefulWidget {
  @override
  _BeverageScreenState createState() => _BeverageScreenState();
}

class _BeverageScreenState extends State<BeverageScreen> {
  String selectedCategory = 'All';
  String? userId;
  String? userDocumentId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      await _getUserDocumentIdByEmail(user.email!);
    } else {
      print('User is not logged in');
    }
  }

  Future<void> _getUserDocumentIdByEmail(String email) async {
    try {
      final userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        setState(() {
          userDocumentId = userQuerySnapshot.docs.first.id;
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error getting user document by email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('GreenMart'),
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShoppingCartPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Category filter buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryButton('All', selectedCategory == 'All'),
                _buildCategoryButton('Juice', selectedCategory == 'Juice'),
                _buildCategoryButton('Soft Drinks', selectedCategory == 'Soft Drinks'),
                _buildCategoryButton('Water', selectedCategory == 'Water'),
              ],
            ),
          ),
          // Product list
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('beverages').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var beverages = snapshot.data!.docs;
                // Filter beverages based on the selected category
                var filteredBeverages = beverages.where((beverage) {
                  if (selectedCategory == 'All') {
                    return true;
                  } else if (selectedCategory == 'Juice') {
                    return beverage['productCategory'] == 'Juice';
                  } else if (selectedCategory == 'Soft Drinks') {
                    return beverage['productCategory'] == 'Soft Drinks';
                  } else if (selectedCategory == 'Water') {
                    return beverage['productCategory'] == 'Water';
                  }
                  return false;
                }).toList();

                return ListView.builder(
                  itemCount: filteredBeverages.length,
                  itemBuilder: (context, index) {
                    var beverage = filteredBeverages[index].data() as Map<String, dynamic>;
                    beverage['id'] = filteredBeverages[index].id;

                    // Get stock count for each month from the inStockMonth map
                    int stockCount = 0;
                    beverage['inStockMonth'].forEach((month, data) {
                      stockCount += (data['stockCount'] as num).toInt(); // Cast to int
                    });

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Display product image from Firebase Storage using the URL
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      beverage['productImage'], // URL from Firestore
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.broken_image, size: 100, color: Colors.grey);
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // Display product details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          beverage['productName'],
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          '${beverage['company']}',
                                          style: TextStyle(fontSize: 14, color: Colors.grey),
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Rs ${beverage['finalPrice'].toString()}',
                                          style: TextStyle(fontSize: 16, color: Colors.black87),
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          '$stockCount items Available', // Display total stock count
                                          style: TextStyle(fontSize: 14, color: Colors.green),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Add and subtract buttons with availability check
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.add_circle, color: Colors.green),
                                        onPressed: (stockCount > 0) // Use stockCount directly
                                            ? () {
                                                addToCart(beverage);
                                              }
                                            : null,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.remove_circle, color: Colors.red),
                                        onPressed: () {
                                          removeFromCart(beverage);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (stockCount == 0) // Display out of stock message
                                Text(
                                  'Out of Stock',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to build category filter buttons
  Widget _buildCategoryButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = text;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.lightGreen : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.lightGreen, width: 2),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.lightGreen,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Function to add item to cart and update stock availability
  Future<void> addToCart(Map<String, dynamic> beverage) async {
    if (userDocumentId == null) {
      print('User document ID is not available');
      return;
    }

    try {
      final cartDoc = FirebaseFirestore.instance.collection('cart').doc(userDocumentId);
      final cartSnapshot = await cartDoc.get();

      List<Map<String, dynamic>> items = [];
      double total = 0.0;

      if (cartSnapshot.exists) {
        items = List<Map<String, dynamic>>.from(cartSnapshot['items'] ?? []);
        total = (cartSnapshot['total'] ?? 0.0).toDouble();
      }

      // Check if beverage is already in the cart
      final existingItemIndex = items.indexWhere((item) => item['id'] == beverage['id']);
      if (existingItemIndex != -1) {
        items[existingItemIndex]['quantity'] += 1; // Increment quantity
      } else {
        // If not in cart, add new item
        items.add({
          'id': beverage['id'],
          'name': beverage['productName'],
          'quantity': 1,
          'price': beverage['finalPrice'],
        });
      }

      total += beverage['finalPrice'];

      // Update beverage stock in Firestore
      final month = 'January'; // Replace with the current month as needed
      final stockCount = beverage['inStockMonth'][month]['stockCount'] as int;

      if (stockCount > 0) {
        // Deduct stock count
        await FirebaseFirestore.instance.collection('beverages').doc(beverage['id']).update({
          'inStockMonth.$month.stockCount': stockCount - 1,
        });
      } else {
        print('Stock is not available for this beverage');
        return;
      }

      // Update cart in Firestore
      await cartDoc.set({
        'items': items,
        'total': total,
      });

      print('Item added to cart');
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  // Function to remove item from cart
  Future<void> removeFromCart(Map<String, dynamic> beverage) async {
    if (userDocumentId == null) {
      print('User document ID is not available');
      return;
    }

    try {
      final cartDoc = FirebaseFirestore.instance.collection('cart').doc(userDocumentId);
      final cartSnapshot = await cartDoc.get();

      if (cartSnapshot.exists) {
        List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(cartSnapshot['items'] ?? []);
        double total = (cartSnapshot['total'] ?? 0.0).toDouble();

        final existingItemIndex = items.indexWhere((item) => item['id'] == beverage['id']);
        if (existingItemIndex != -1) {
          final quantity = items[existingItemIndex]['quantity'];
          if (quantity > 1) {
            // Decrease quantity if more than 1
            items[existingItemIndex]['quantity'] -= 1;
            total -= beverage['finalPrice'];
          } else {
            // Remove item if quantity is 1
            items.removeAt(existingItemIndex);
            total -= beverage['finalPrice'];
          }

          // Update cart in Firestore
          await cartDoc.set({
            'items': items,
            'total': total,
          });

          // Update beverage stock in Firestore
          final month = 'January'; // Replace with the current month as needed
          final stockCount = beverage['inStockMonth'][month]['stockCount'] as int;

          // Increment stock count
          await FirebaseFirestore.instance.collection('beverages').doc(beverage['id']).update({
            'inStockMonth.$month.stockCount': stockCount + 1,
          });

          print('Item removed from cart');
        } else {
          print('Item not found in cart');
        }
      } else {
        print('Cart does not exist for the user');
      }
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }
}
