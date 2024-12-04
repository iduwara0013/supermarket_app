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
    {'label': 'Dairy & Eggs', 'image': 'assets/dairy1.png', 'color': Color(0xFFFFE9E5)},
    {'label': 'Meats & Seafood', 'image': 'assets/meats1.webp', 'color': Color(0xFFDCF4F5)},
    {'label': 'Grocery', 'image': 'assets/grocery1.png', 'color': Color(0xFFFFF5D2)},
    {'label': 'Bakery Products', 'image': 'assets/bakery1.png', 'color': Color(0xFFEFE5FF)},
    {'label': 'Snacks', 'image': 'assets/snacks1.jpg', 'color': Color(0xFFFFF5D2)},
    {'label': 'Beverages', 'image': 'assets/beverages1.png', 'color': Color(0xFFE6F3EA)},
    {'label': 'Health & Wellness', 'image': 'assets/health1.png', 'color': Color(0xFFE6F3EA)},
    {'label': 'Frozen Foods', 'image': 'assets/frozen1.png', 'color': Color(0xFFFFF5D2)},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => OrderScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF0F4F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two items per row for better visibility
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  // Navigate to Beverage screen if the selected category is Beverages
                  if (categories[index]['label'] == 'Beverages') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BeveragesScreen()),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: categories[index]['color'],
                        radius: 50,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            categories[index]['image']!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        categories[index]['label']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// Updated BottomNavBar
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
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
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
