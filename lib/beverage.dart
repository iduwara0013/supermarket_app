import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BeveragesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.menu),
            Row(
              children: [
                Icon(Icons.shopping_cart),
                SizedBox(width: 10),
                Text('Rs.5000.00'),
                SizedBox(width: 20),
                Icon(Icons.person),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'What do you want?',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 20),

            // Category filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryButton("All", isSelected: true),
                  _buildCategoryButton("Juice"),
                  _buildCategoryButton("Malt"),
                  _buildCategoryButton("Tea"),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Fetching data from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('beverages').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final beverages = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: beverages.length,
                    itemBuilder: (context, index) {
                      var beverage = beverages[index];
                      return _buildBeverageItem(
                        name: beverage['productName'],
                        price: beverage['finalPrice'],
                        imageUrl: beverage['productImage'], // Fetching image URL from Firestore
                        availableQuantity: beverage['stock'],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build category buttons
  Widget _buildCategoryButton(String title, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green[100] : Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {},
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.green : Colors.black,
          ),
        ),
      ),
    );
  }

  // Method to build each beverage item row
  Widget _buildBeverageItem({required String name, required double price, required String imageUrl, required int availableQuantity}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image loaded from Firestore URL
              Image.network(
                imageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
              ),
              SizedBox(width: 20),
              
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Rs. ${price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '$availableQuantity Item Available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Add/Remove buttons
              Column(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.add_circle, color: Colors.green),
                  ),
                  SizedBox(height: 10),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
