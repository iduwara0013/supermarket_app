import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shopping_cart.dart'; // Import your shopping cart page

class SnacksPage extends StatefulWidget {
  @override
  _SnacksPageState createState() => _SnacksPageState();
}

class _SnacksPageState extends State<SnacksPage> {
  String selectedCategory = "All"; // Default category
  List<String> categories = ["All", "Juice", "Soft Drinks", "Water", "Snacks"];

  // Fetch the current user ID from the current_user collection
  Future<String> getCurrentUserId() async {
    var currentUserSnapshot = await FirebaseFirestore.instance
        .collection('current_user')
        .doc('current') // Replace with logic to fetch the current document ID
        .get();

    return currentUserSnapshot.data()?['userId'] ?? 'UNKNOWN_USER_ID'; // Return userId
  }

  // Function to increase stock count (decrease the total available stock)
  void _incrementStock(DocumentSnapshot product) async {
    int currentStock = product['inStockMonth']['totalStock'] ?? 0; // Default to 0 if field is missing
    if (currentStock > 0) {
      await FirebaseFirestore.instance
          .collection('snacks')
          .doc(product.id)
          .update({'inStockMonth.totalStock': currentStock - 1});
    }
  }

  // Function to decrease stock count (increase the total available stock)
  void _decrementStock(DocumentSnapshot product) async {
    int currentStock = product['inStockMonth']['totalStock'] ?? 0; // Default to 0 if field is missing
    await FirebaseFirestore.instance
        .collection('snacks')
        .doc(product.id)
        .update({'inStockMonth.totalStock': currentStock + 1});
  }

  // Function to add the product to the cart
  Future<void> _addToCart(DocumentSnapshot product) async {
    String userId = await getCurrentUserId(); // Get the actual user ID dynamically

    var cartDocRef = FirebaseFirestore.instance.collection('cart').doc(userId);
    
    // Create a new cart document if it doesn't exist
    var cartSnapshot = await cartDocRef.get();
    if (!cartSnapshot.exists) {
      await cartDocRef.set({'items': [], 'totalPrice': 0}); // Initialize cart document
    }
    
    // Get the updated cart items
    cartSnapshot = await cartDocRef.get();
    List<dynamic> cartItems = List.from(cartSnapshot.data()?['items'] ?? []);

    // Check if the item already exists in the cart
    bool itemExists = false;
    for (var item in cartItems) {
      if (item['name'] == product['productName']) {
        item['quantity']++;
        itemExists = true;
        break;
      }
    }

    // If the item doesn't exist, add it to the cart
    if (!itemExists) {
      cartItems.add({
        'name': product['productName'],
        'price': product['finalPrice'],
        'quantity': 1,
      });
    }

    // Update the cart document
    await cartDocRef.set({
      'items': cartItems,
      'totalPrice': cartItems.fold<int>(
        0,
        (total, item) => total + (item['price'] as int) * (item['quantity'] as int),
      ),
    }, SetOptions(merge: true));

    // Decrement the stock after adding to the cart
    _incrementStock(product);

    // Optionally, you can show a Snackbar or dialog to inform the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['productName']} added to cart')),
    );
  }

  // Function to remove the product from the cart
  Future<void> _removeFromCart(DocumentSnapshot product) async {
    String userId = await getCurrentUserId(); // Get the actual user ID dynamically

    var cartDocRef = FirebaseFirestore.instance.collection('cart').doc(userId);
    
    var cartSnapshot = await cartDocRef.get();
    List<dynamic> cartItems = List.from(cartSnapshot.data()?['items'] ?? []);

    // Find the item in the cart
    for (var item in cartItems) {
      if (item['name'] == product['productName']) {
        item['quantity']--;
        if (item['quantity'] <= 0) {
          cartItems.remove(item); // Remove item if quantity is zero
        }
        break;
      }
    }

    // Update the cart document
    await cartDocRef.set({
      'items': cartItems,
      'totalPrice': cartItems.fold<int>(
        0,
        (total, item) => total + (item['price'] as int) * (item['quantity'] as int),
      ),
    }, SetOptions(merge: true));

    // Increment stock after removing from the cart
    _decrementStock(product);

    // Optionally, you can show a Snackbar or dialog to inform the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['productName']} removed from cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Snacks"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingCartPage()), // Navigate to ShoppingCart
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10.0),
          Container(
            height: 50.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return CategoryButton(
                  text: categories[index],
                  selected: selectedCategory == categories[index],
                  onTap: () {
                    setState(() {
                      selectedCategory = categories[index];
                    });
                  },
                );
              },
            ),
          ),
          SizedBox(height: 10.0),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('snacks')
                  .where('productCategory', isEqualTo: selectedCategory == "All" ? null : selectedCategory)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var product = products[index];
                    int currentStock = product['inStockMonth']['totalStock'] ?? 0; // Handle missing field
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // Product Image
                            Container(
                              width: 100,
                              height: 100,
                              child: Image.network(
                                product['productImage'] ?? '', // Handle missing field
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 16.0),
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['productName'] ?? 'Unknown Product', // Handle missing field
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    "Rs ${product['finalPrice'] ?? 0}", // Handle missing field
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    "$currentStock Item(s) Available",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Add Button
                            IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              color: Colors.green,
                              onPressed: () {
                                _addToCart(product); // Add to cart functionality
                              },
                            ),
                            // Remove Button
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              color: Colors.red,
                              onPressed: () {
                                _removeFromCart(product); // Remove from cart functionality
                              },
                            ),
                          ],
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
}

class CategoryButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  CategoryButton({required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: selected ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Center(child: Text(text)),
      ),
    );
  }
}
