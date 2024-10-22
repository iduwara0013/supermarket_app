import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shopping_cart.dart' as shoppingCart; // Prefix for avoiding ambiguity

void main() {
  runApp(MaterialApp(
    home: GroceryPage(),
  ));
}

class GroceryPage extends StatefulWidget {
  @override
  _GroceryPageState createState() => _GroceryPageState();
}

class _GroceryPageState extends State<GroceryPage> {
  String selectedCategory = 'All';
  String userId = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    var userSnapshot = await FirebaseFirestore.instance.collection('current_user').doc('current').get();
    if (userSnapshot.exists) {
      setState(() {
        userId = userSnapshot.data()?['userId'] ?? '';
      });
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
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Center(
              child: Text('Rs.900.00', style: TextStyle(color: Colors.white)),
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'What are you looking for',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CategoryButton(text: 'All', selected: selectedCategory == 'All', onTap: () => _selectCategory('All')),
                      CategoryButton(text: 'Flour', selected: selectedCategory == 'Flour', onTap: () => _selectCategory('Flour')),
                      CategoryButton(text: 'Sugar', selected: selectedCategory == 'Sugar', onTap: () => _selectCategory('Sugar')),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('grocery').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var products = snapshot.data!.docs;
                      var filteredProducts = products.where((product) {
                        if (selectedCategory == 'All') {
                          return true;
                        }
                        return product['productCategory'] == selectedCategory;
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
                              imageUrl: product['productImage'],
                              name: product['productName'],
                              price: 'Rs ${product['finalPrice']}',
                              company: product['company'] ?? 'Unknown',
                              stockCount: product['inStockMonth']['totalStock'] ?? 0, // Access totalStock directly
                              product: product,
                              onAdd: () => addToCart(product),
                              onRemove: () => removeFromCart(product),
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
        'category': product['productCategory'],
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

    // Update stock for the current month without creating a new field
    int currentMonth = DateTime.now().month;
    await FirebaseFirestore.instance.collection('grocery').doc(product['id']).update({
      'inStockMonth.totalStock': FieldValue.increment(-1), // Decrease stock count directly
    });
  }

  Future<void> removeFromCart(Map<String, dynamic> product) async {
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

    for (var item in cartItems) {
      if (item['name'] == product['productName']) {
        if (item['quantity'] > 1) {
          item['quantity']--;
          totalPrice -= productPrice;
        } else {
          totalPrice -= productPrice;
          cartItems.remove(item);
        }
        break;
      }
    }

    await cartDocRef.set({
      'items': cartItems,
      'totalPrice': totalPrice,
    }, SetOptions(merge: true));

    // Update stock for the current month without creating a new field
    int currentMonth = DateTime.now().month;
    await FirebaseFirestore.instance.collection('grocery').doc(product['id']).update({
      'inStockMonth.totalStock': FieldValue.increment(1), // Increase stock count directly
    });
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
  final String company;
  final int stockCount;
  final Map<String, dynamic> product;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ProductItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.company,
    required this.stockCount,
    required this.product,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(8),
      child: Row(
        children: [
          Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(company),
                  Text(price, style: const TextStyle(color: Colors.green)),
                  Text('Stock: $stockCount', style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: stockCount > 0 ? onAdd : null,
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: stockCount > 0 ? onRemove : null,
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
        title: Text(product['productName']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product['productImage']),
            const SizedBox(height: 16.0),
            Text(
              'Price: Rs ${product['finalPrice']}',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text('Company: ${product['company'] ?? 'Unknown'}'),
            const SizedBox(height: 8.0),
            Text('Stock: ${product['inStockMonth']['totalStock'] ?? 0}'), // Get total stock directly
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
