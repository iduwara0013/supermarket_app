import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/services.dart';
import 'package:my_first_app/cleaning.dart';
import 'dairy.dart';
import 'beverage.dart';
import 'profile_information.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'frozen.dart';
import 'shopping_cart.dart';
import 'setting.dart';
import 'category.dart';
import 'fresco_registration.dart'; 
import 'snacks.dart';
import 'HealthWellness.dart';
import 'BakeryProducts.dart';
import 'Meats_Seafood.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _selectedIndex = 0;
   List<String> _imageUrls = []; // Store image URLs from Firestore
  
  @override
  void initState() {
    super.initState();
    _fetchPromotions();
    _autoScrollImages();
  }

  // Fetch image URLs from Firebase Firestore
  Future<void> _fetchPromotions() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('promotions')
          .get();

      setState(() {
        _imageUrls = querySnapshot.docs
            .map((doc) => doc['imageUrl'] as String)
            .toList();
      });
    } catch (e) {
      print('Error fetching promotions: $e');
    }
  }

  void _autoScrollImages() {
    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (_imageUrls.isNotEmpty) {
        int nextPage = _currentPage + 1;
        if (nextPage == _imageUrls.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on the selected index
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1: // Search
        // Implement search page navigation
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchPage()),
        );
        break;
      case 2: // Categories
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CategoryPage()),
        );
        break;
      case 3: // Settings
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
      case 4: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileInformationPage()),
        );
        break;
      case 5: // Shopping Cart
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ShoppingCartPage()),
        );
        break;
      default:
        break;
    }
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex == 0) {
      SystemNavigator.pop();
      return Future.value(false);
    } else {
      setState(() {
        _selectedIndex = 0;
      });
      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 58, 104, 16),
          automaticallyImplyLeading: false,
          toolbarHeight: 80, // Adjust the height of the AppBar
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white), // Change icon color to white
                onPressed: () {},
              ),
              const SizedBox(width: 8), // Optional spacing between the menu icon and logo
              Image.asset(
                'assets/logo.png',
                height: 40,
              ),
              const Spacer(), // Pushes the following icons to the right side
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white), // Change icon color to white
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ShoppingCartPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white), // Change icon color to white
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileInformationPage()),
                  );
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Search Bar
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'What are you looking for',
                          prefixIcon: Icon(Icons.search), // Keep the search icon
                          border: InputBorder.none, // Remove the border
                          hintStyle: TextStyle(color: Colors.grey), // Optional: Change hint text color
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
              ),
              // Image carousel with auto-scroll and dots indicator
SizedBox(
  height: 190,
  width: 400,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(35.0), // Adjust the radius for curve effect
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0), // Add space on left and right
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _autoScrollImages();
            },
            itemCount: _imageUrls.length,
            itemBuilder: (context, index) {
              return Image.network(
                _imageUrls[index], // Fetch the image from Firestore
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              );
            },
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: DotsIndicator(
                dotsCount: _imageUrls.length,
                position: _currentPage.toInt(),
                decorator: DotsDecorator(
                  activeColor: Colors.green,
                  size: const Size.square(9.0),
                  activeSize: const Size(18.0, 9.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),


              // Categories Section
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft, // Align text to the left
                  child: Text(
                    'CATEGORIES',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(93, 95, 90, 1),
                    ),
                  ),
                ),
              ),
              // Horizontal list of categories
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CategoryCard('Grocery', 'assets/grocery1.png', GroceryPage()),
                    CategoryCard('Frozen Foods', 'assets/frozen1.png', FrozonPage()),
                    CategoryCard('Beverage', 'assets/beverages1.png', BeveragesScreen()),
                    CategoryCard('Snacks', 'assets/snacks1.jpg', SnacksPage()),
                    CategoryCard('Meats & Seafood', 'assets/meats1.webp', MeatsSeafoodPage()),
                    CategoryCard('Health & Wellness', 'assets/health1.png', HealthPage()),
                    CategoryCard('Bakery Products', 'assets/bakery1.png', BakeryProductsPage()),
                    CategoryCard('Dairy & Eggs', 'assets/dairy1.png', DairyPage()),
                  ],
                ),
              ),
              // GreenMart Deals Section
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft, // Aligns text to the left
                  child: Text(
                    'GreenMart Deals',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(93, 95, 90, 1),
                    ),
                  ),
                ),
              ),
              DealSection('GreenMart Deals'),
              // Best Sellers Section
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft, // Aligns text to the left
                  child: Text(
                    'Best Sellers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(93, 95, 90, 1),
                    ),
                  ),
                ),
              ),
              DealSection('Best Sellers'),
              // Fresco Deals Section
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft, // Aligns text to the left
                  child: Text(
                    'Fresco Deals',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(93, 95, 90, 1),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 229, 255, 205),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    // Text on the left side
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Center the text vertically
                        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                        children: [
                          Text(
                            'Buy 1 Get 1 Free!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fresco Brand Vegetables',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Image on the right side
                    
                    const SizedBox(width: 8), // Space between image and button
                    // Add to Cart button
                    ElevatedButton.icon(
                      onPressed: () {
                        // Add to cart functionality
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 229, 255, 205),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    // Text on the left side
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Center the text vertically
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fresco',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Deals that help you\nSave Your Weekly Shopping.',
                            style: TextStyle(
                              color: Color.fromARGB(255, 32, 5, 139),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const FrescoRegistration()),
                              );
                            },
                            child: const Text('Fresco Registration'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.green,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16), // Space between text and image
                    // Image on the right side with increased size
                    Image.asset(
                      'assets/fresco_logo.png', // Replace with your image asset
                      width: 150, // Increased width
                      height: 150, // Increased height
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      ),
    );
  }
}

// Category Card Widget
class CategoryCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Widget? page;

  const CategoryCard(this.title, this.imagePath, this.page, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page!),
          );
        }
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5.0,
              spreadRadius: 2.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 60,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// Deal Section Widget
class DealSection extends StatelessWidget {
  final String title;

  const DealSection(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5.0,
            spreadRadius: 2.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Search Page (for demonstration purposes)
class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Center(
        child: const Text('Search Page'),
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
