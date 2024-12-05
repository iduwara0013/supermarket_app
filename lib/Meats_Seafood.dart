import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shopping_cart.dart' as shoppingCart;

void main() {
  runApp(MaterialApp(
    home: MeatsSeafoodPage(),
  ));
}

class MeatsSeafoodPage extends StatefulWidget {
  @override
  _MeatsSeafoodPageState createState() => _MeatsSeafoodPageState();
}

class _MeatsSeafoodPageState extends State<MeatsSeafoodPage> {
  String selectedCategory = 'All';
  String userId = '';
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
   double totalPrice = 0.0; // New state variable for total price
    bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
     searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
    });
  }
   @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserId() async {
    var userSnapshot = await FirebaseFirestore.instance.collection('current_user').doc('current').get();
    if (userSnapshot.exists) {
      setState(() {
        userId = userSnapshot.data()?['userId'] ?? '';
      });
      _fetchTotalPrice(); // Fetch total price after getting userId
    }
  }

  Future<void> _fetchTotalPrice() async {
    if (userId.isNotEmpty) {
      var cartDocRef = FirebaseFirestore.instance.collection('cart').doc(userId);
      var cartSnapshot = await cartDocRef.get();
      if (cartSnapshot.exists) {
        var totalPriceData = cartSnapshot.data()?['totalPrice'];
        if (totalPriceData is String) {
          totalPrice = double.tryParse(totalPriceData) ?? 0.0;
        } else if (totalPriceData is num) {
          totalPrice = totalPriceData.toDouble();
        }
        setState(() {}); // Update state to refresh UI with the total price
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: const Icon(Icons.menu, color: Colors.white),
        title: const Text('Green Mart', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: Text('Rs.${totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)), // Updated to show dynamic total price
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => shoppingCart.ShoppingCartPage()),
              );
            },
          ),
        ],
      ),
       body: userId.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'What are you looking for',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Padding(
  padding: const EdgeInsets.symmetric(horizontal: 8.0),
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal, // Enable horizontal scrolling
    child: Row(
      children: [
        CategoryButton(
          text: 'All',
          selected: selectedCategory == 'All',
          onTap: () => _selectCategory('All'),
        ),
        CategoryButton(
          text: 'Chicken',
          selected: selectedCategory == 'Chicken',
          onTap: () => _selectCategory('Chicken'),
        ),
        CategoryButton(
          text: 'Beef',
          selected: selectedCategory == 'Beef',
          onTap: () => _selectCategory('Beef'),
        ),
        CategoryButton(
          text: 'Pork',
          selected: selectedCategory == 'Pork',
          onTap: () => _selectCategory('Pork'),
        ),
        CategoryButton(
          text: 'Fish',
          selected: selectedCategory == 'Fish',
          onTap: () => _selectCategory('Fish'),
        ),
        
      ],
    ),
  ),
),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('meats&seafoods').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var products = snapshot.data!.docs;
                      var filteredProducts = products.where((product) {
                        var productName = product['productName'].toString().toLowerCase();
                        var matchesCategory = selectedCategory == 'All' || product['subCategory'] == selectedCategory;
                        var matchesSearch = productName.contains(searchQuery);

                        return matchesCategory && matchesSearch;
                      }).toList();

                      return ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          var product = filteredProducts[index].data() as Map<String, dynamic>;
                          product['id'] = filteredProducts[index].id;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
                              );
                            },
                            child: ProductItem(
                              imageUrl: product['productImage'] ?? '',
                              name: product['productName'] ?? 'Unknown',
                              price: 'Rs ${product['finalPrice'] ?? '0.00' }',
                              product: product,
                              onAdd: () => addToCart(product),
                              onRemove: () => removeFromCart(product),
                              outOfStock: product['inStockMonth']['totalStock'] == 0, // Add this line
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

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

Future<void> addToCart(Map<String, dynamic> product) async {
    var cartDocRef = FirebaseFirestore.instance.collection('cart').doc(userId);

    var cartSnapshot = await cartDocRef.get();
    List<dynamic> cartItems = List.from(cartSnapshot.data()?['items'] ?? []);

    double totalPrice = 0.0;
    var totalPriceData = cartSnapshot.data()?['totalPrice'];
    if (totalPriceData is String) {
      totalPrice = double.tryParse(totalPriceData) ?? 0.0;
    } else if (totalPriceData is num) {
      totalPrice = totalPriceData.toDouble();
    }

    double productPrice = 0.0;
    var finalPrice = product['finalPrice'];
    if (finalPrice is String) {
      productPrice = double.tryParse(finalPrice) ?? 0.0;
    } else if (finalPrice is num) {
      productPrice = finalPrice.toDouble();
    }

    bool itemExists = false;
    for (var item in cartItems) {
      if (item['name'] == product['productName']) {
        item['quantity']++;
        totalPrice += productPrice;
        itemExists = true;
        break;
      }
    }

    if (!itemExists) {
      cartItems.add({
        'quantityType': product['quantityType'],
        'name': product['productName'],
        'price': productPrice,
        'quantity': 1,
      });
      totalPrice += productPrice;
    }

    await cartDocRef.set({
      'items': cartItems,
      'totalPrice': totalPrice,
    }, SetOptions(merge: true));

    // Update the total stock count in the beverages collection
    await FirebaseFirestore.instance.collection('meats&seafoods').doc(product['id']).update({
      'inStockMonth.totalStock': FieldValue.increment(-1),
    });

    _fetchTotalPrice(); // Fetch total price after adding
  }

  Future<void> removeFromCart(Map<String, dynamic> product) async {
  var cartDocRef = FirebaseFirestore.instance.collection('cart').doc(userId);

  try {
    var cartSnapshot = await cartDocRef.get();
    List<dynamic> cartItems = List.from(cartSnapshot.data()?['items'] ?? []);
    double totalPrice = 0.0;

    // Ensure totalPrice is extracted correctly
    var totalPriceData = cartSnapshot.data()?['totalPrice'];
    if (totalPriceData is String) {
      totalPrice = double.tryParse(totalPriceData) ?? 0.0;
    } else if (totalPriceData is num) {
      totalPrice = totalPriceData.toDouble();
    }

    double productPrice = 0.0;
    var finalPrice = product['finalPrice'];
    if (finalPrice is String) {
      productPrice = double.tryParse(finalPrice) ?? 0.0;
    } else if (finalPrice is num) {
      productPrice = finalPrice.toDouble();
    }

    bool itemFound = false;

    for (var item in cartItems) {
      if (item['name'] == product['productName']) {
        itemFound = true;

        // Decrease quantity if greater than 1, otherwise remove item
        if (item['quantity'] > 1) {
          item['quantity']--;
          totalPrice -= productPrice; // Subtract price for each quantity
        } else {
          totalPrice -= productPrice; // Subtract price for removal
          cartItems.remove(item); // Remove item from cart
        }
        break; // Exit loop after modifying the item
      }
    }

    if (!itemFound) {
      print('Item not found in cart.');
      return; // If item is not found, exit the function
    }

    // Update cart document with modified items and totalPrice
    await cartDocRef.set({
      'items': cartItems,
      'totalPrice': totalPrice,
    }, SetOptions(merge: true));

    // Update the total stock count in the beverages collection
    await FirebaseFirestore.instance.collection('meats&seafoods').doc(product['id']).update({
      'inStockMonth.totalStock': FieldValue.increment(1),
    });

  } catch (e) {
    print("Error removing from cart: $e");
  }
}

}



class CategoryButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: selected ? Colors.white : Colors.black,
        backgroundColor: selected ? Colors.green : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Colors.green),
        ),
      ),
      onPressed: onTap,
      child: Text(text),
    );
  }
}
class ProductItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;
  final Map<String, dynamic> product;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool outOfStock;

  const ProductItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.product,
    required this.onAdd,
    required this.onRemove,
    required this.outOfStock,  // Added outOfStock parameter
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(8),
      child: Row(
        children: [
          // Product Image
          Image.network(
            imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  // Product Price
                  Text(price, style: const TextStyle(color: Colors.green)),
                  // Product Quantity Type (e.g., kg, liters)
                  Text(product['quantityType'] ?? 'Unknown'), // Display quantityType or Unknown
                  // Out of Stock label
                  if (outOfStock)
                    const Text('Out of Stock', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
          // Add and Remove buttons
          Column(
            children: [
              // Add button
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: outOfStock ? null : onAdd,  // Disable if out of stock
              ),
              // Remove button
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: outOfStock ? null : onRemove,  // Disable if out of stock
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['productName'] ?? 'Product Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product['productImage'] ?? ''),
            const SizedBox(height: 16.0),
            Text(
              'Price: Rs ${product['finalPrice'] ?? '0.00'}',
              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(product['quantityType'] ?? 'Unknown'),  // Show value only
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                // Logic to add to cart can be implemented here
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
