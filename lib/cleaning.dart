import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shopping_cart.dart';

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
  final String userId = 'your_user_id'; // Replace with your user ID

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
                MaterialPageRoute(builder: (context) => ShoppingCartPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
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

          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryButton(text: 'All', selected: selectedCategory == 'All', onTap: () => _selectCategory('All')),
                CategoryButton(text: 'Flour', selected: selectedCategory == 'Flour', onTap: () => _selectCategory('Flour')),
                CategoryButton(text: 'Sugar', selected: selectedCategory == 'Sugar', onTap: () => _selectCategory('Sugar')),
                // Add more categories as needed
              ],
            ),
          ),

          // Product List
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

                    return ProductItem(
                      imageUrl: product['productImage'],
                      name: product['productName'],
                      price: 'Rs ${product['finalPrice']}',
                      company: product['company'] ?? 'Unknown',
                      stockCount: product['stockCount'] ?? 0,
                      product: product,
                      onAdd: () => addToCart(product),
                      onRemove: () => removeFromCart(product),
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
    var cartDoc = FirebaseFirestore.instance.collection('shoppingCart').doc(userId);
    await cartDoc.set({
      'products': FieldValue.arrayUnion([product]),
    }, SetOptions(merge: true));
  }

  Future<void> removeFromCart(Map<String, dynamic> product) async {
    var cartDoc = FirebaseFirestore.instance.collection('shoppingCart').doc(userId);
    await cartDoc.update({
      'products': FieldValue.arrayRemove([product]),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Display product image from Firebase Storage using the URL
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
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
              const SizedBox(width: 16),

              // Display product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      company,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      price,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$stockCount items Available',
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),

              // Add and subtract buttons with availability check
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: (stockCount > 0) ? onAdd : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: onRemove,
                  ),
                ],
              ),
            ],
          ),

          // Display out-of-stock message if stock count is zero
          if (stockCount == 0)
            const Text(
              'Out of Stock',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
