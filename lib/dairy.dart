import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: DairyPage()));
}

class DairyPage extends StatefulWidget {
  const DairyPage({super.key});

  @override
  _DairyPageState createState() => _DairyPageState();
}

class _DairyPageState extends State<DairyPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _products = [];
  List<DocumentSnapshot> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
  try {
    var querySnapshot = await _firestore.collection('dairyProduct').get();
    setState(() {
      _products = querySnapshot.docs;
      _filteredProducts = _products;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    print('Error fetching products: $e'); // Add this line to see any errors
  }
}


  // Filter products based on search query
  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          var name = data['name'].toString().toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DAIRY'),
        backgroundColor: Colors.green,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: 'Search products...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredProducts.isEmpty
              ? const Center(child: Text('No Data Found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: _filteredProducts.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    int stockCount = data['stock'] ?? 0;
                    String availability = stockCount > 0
                        ? 'In Stock ($stockCount available)'
                        : 'Out of Stock';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ProductItem(
                        imageUrl: 'assets/dairy.jpg', // Update path if image name changes
                        price: data['price'].toString(),
                        name: data['productName'].toString(),
                        size: data['size'].toString(),
                        discount: data['discount'].toString(),
                        nutriGrade: data['nutriGrade'].toString(),
                        availability: availability,
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final String imageUrl;
  final String price;
  final String name;
  final String size;
  final String discount;
  final String nutriGrade;
  final String availability;

  const ProductItem({super.key, 
    required this.imageUrl,
    required this.price,
    required this.name,
    required this.size,
    required this.discount,
    required this.nutriGrade,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        SizedBox(
          width: 110,
          height: 150,
          child: Image.asset(imageUrl, fit: BoxFit.cover),
        ),
        const SizedBox(width: 16),
        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  if (discount.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      color: Colors.yellow,
                      child: Text(
                        discount,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                size,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Nutri-Grade: $nutriGrade',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    availability,
                    style: TextStyle(
                      fontSize: 14,
                      color: availability.contains('Out of Stock')
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
