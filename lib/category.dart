import 'package:flutter/material.dart';
import 'shopping_cart.dart'; // Import the ShoppingCartPage
import 'setting.dart'; // Import the SettingsPage
import 'homescreen.dart';
import 'beverage.dart'; // Import your Beverage screen
import 'order.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  int _selectedIndex = 2; // Default index for Categories tab

  // Add the list of categories with corresponding image assets, labels, and custom properties
  final List<Map<String, dynamic>> categories = [
    {'label': 'Dairy & Eggs', 'image': 'assets/dairy1.png', 'color': Color(0xFFFFE9E5), 'imageSize': 120.0},
    {'label': 'Meats & Seafood', 'image': 'assets/meats1.png', 'color': Color(0xFFDCF4F5), 'imageSize': 60.0},
    {'label': 'Grocery', 'image': 'assets/grocery1.png', 'color': Color(0xFFFFF5D2), 'imageSize': 80.0},
    {'label': 'Bakery Products', 'image': 'assets/bakery1.png', 'color': Color(0xFFEFE5FF), 'imageSize': 65.0},
    {'label': 'Snacks', 'image': 'assets/snacks1.png', 'color': Color(0xFFFFF5D2), 'imageSize': 20.0},
    {'label': 'Beverages', 'image': 'assets/beverages1.png', 'color': Color(0xFFE6F3EA), 'imageSize': 55.0},
    {'label': 'Health & Wellness', 'image': 'assets/health1.png', 'color': Color(0xFFE6F3EA), 'imageSize': 80.0},
    {'label': 'Frozen Foods', 'image': 'assets/frozen1.png', 'color': Color(0xFFFFF5D2), 'imageSize': 70.0},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()), // Replace HomeScreen with your home page
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrderScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Three items per row
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1, // Adjust the aspect ratio for item width/height ratio
          ),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                // Navigate to Beverage screen if the selected category is Beverages
                if (categories[index]['label'] == 'Beverages') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BeveragesScreen()), // Navigate to your Beverage screen
                  );
                }
              },
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: 110.0,  // Adjust the overall size of the circle container
                      height: 110.0, // Adjust the overall size of the circle container
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: categories[index]['color'], // Custom background color per item
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0), // Adjust padding inside the circle
                        child: Image.asset(
                          categories[index]['image']!,
                          width: categories[index]['imageSize'], // Custom image width per item
                          height: categories[index]['imageSize'], // Custom image height per item
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categories[index]['label']!,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// Reuse the BottomNavBar from the previous code
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notification',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: onItemTapped,
    );
  }
}
