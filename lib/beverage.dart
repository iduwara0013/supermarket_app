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
  String? userId; // To store the current user ID
  String? userDocumentId; // To store the user's document ID from 'users' collection

  @override
  void initState() {
    super.initState();
    _getCurrentUserId(); // Retrieve user ID when the widget initializes
  }

  Future<void> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid; // Store the user ID
      });
      await _getUserDocumentIdByEmail(user.email!); // Get the document ID from 'users' collection using email
    } else {
      print('User is not logged in');
    }
  }

  // Function to get the user's document ID from 'users' collection based on email
  Future<void> _getUserDocumentIdByEmail(String email) async {
    try {
      final userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (userQuerySnapshot.docs.isNotEmpty) {
        setState(() {
          userDocumentId = userQuerySnapshot.docs.first.id; // Store the user's document ID
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
                _buildCategoryButton('Malt', selectedCategory == 'Malt'),
                _buildCategoryButton('Tea', selectedCategory == 'Tea'),
              ],
            ),
          ),
          // Product list
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('beverageProduct').snapshots(),
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
                    return beverage['type'] == 'Juice';
                  } else if (selectedCategory == 'Malt') {
                    return beverage['type'] == 'Malt';
                  } else if (selectedCategory == 'Tea') {
                    return beverage['type'] == 'Tea';
                  }
                  return false;
                }).toList();

                return ListView.builder(
                  itemCount: filteredBeverages.length,
                  itemBuilder: (context, index) {
                    var beverage = filteredBeverages[index].data() as Map<String, dynamic>;
                    beverage['id'] = filteredBeverages[index].id; // Add document ID
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
                                  // Display product image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/${beverage['image']}',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // Display product details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          beverage['name'],
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          '${beverage['size']}',
                                          style: TextStyle(fontSize: 14, color: Colors.grey),
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Rs ${beverage['price'].toString()}',
                                          style: TextStyle(fontSize: 16, color: Colors.black87),
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          '${beverage['availability']} items Available',
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
                                        onPressed: beverage['availability'] > 0
                                            ? () {
                                                addToCart(beverage); // Add to cart
                                              }
                                            : null, // Disable if out of stock
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.remove_circle, color: Colors.red),
                                        onPressed: () {
                                          removeFromCart(beverage); // Remove from cart
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (beverage['availability'] == 0)
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

  // Function to add item to cart and update availability
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

        bool itemExists = false;

        for (var item in items) {
          if (item['name'] == beverage['name']) {
            item['quantity'] += 1;
            itemExists = true;
            break;
          }
        }

        if (!itemExists) {
          items.add({
            'name': beverage['name'],
            'quantity': 1,
            'price': (beverage['price'] as num).toDouble(),
          });
        }

        total += (beverage['price'] as num).toDouble();
      } else {
        items = [
          {
            'name': beverage['name'],
            'quantity': 1,
            'price': (beverage['price'] as num).toDouble(),
          }
        ];
        total = (beverage['price'] as num).toDouble();
      }

      await cartDoc.set({
        'items': items,
        'total': total,
      });

      // Check if the beverage document exists
      final beverageDoc = FirebaseFirestore.instance.collection('beverageProduct').doc(beverage['id']);
      final beverageSnapshot = await beverageDoc.get();

      if (beverageSnapshot.exists) {
        // Update availability if the document exists
        await beverageDoc.update({'availability': beverage['availability'] - 1});
        print('Item added to cart and availability updated.');
      } else {
        // Handle case when the document does not exist
        print('Error: Beverage document not found');
      }

      setState(() {});
    } catch (e) {
      print('Error adding item to cart: $e');
    }
  }

  // Function to remove item from cart and update availability
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

      bool itemRemoved = false;

      for (var item in items) {
        if (item['name'] == beverage['name']) {
          item['quantity'] -= 1;
          if (item['quantity'] <= 0) {
            items.remove(item);
          }
          itemRemoved = true;
          break;
        }
      }

      if (itemRemoved) {
        total -= (beverage['price'] as num).toDouble();

        await cartDoc.set({
          'items': items,
          'total': total,
        });

        // Increase the availability of the beverage product when it is removed from the cart
        final beverageDoc = FirebaseFirestore.instance.collection('beverageProduct').doc(beverage['id']);
        final beverageSnapshot = await beverageDoc.get();

        if (beverageSnapshot.exists) {
          int currentAvailability = beverageSnapshot['availability'] ?? 0;
          await beverageDoc.update({'availability': currentAvailability + 1});
          print('Availability updated after item removed from cart.');
        } else {
          print('Error: Beverage document not found when removing from cart.');
        }

        setState(() {});
      }
    }
  } catch (e) {
    print('Error removing item from cart: $e');
  }
}

}
