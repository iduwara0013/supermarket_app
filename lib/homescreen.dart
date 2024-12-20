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
import 'notification.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false, // Disable the debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.light(
    secondary: Colors.green, // New way
  ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
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
  List<String> _imageUrls = [];
  List<Map<String, dynamic>> _greenMartDeals = [];
  List<Map<String, dynamic>> _bestSellers = [];
  List<Map<String, dynamic>> _frescoDeals = [];
  List<Map<String, dynamic>> _allItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  
  

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
    _autoScrollImages();
    _fetchDeals();
    fetchAllItems().then((items) {
      setState(() {
        _allItems = items;
        _filteredItems = items; // Initially show all items
      });
    });
  }

  Future<List<Map<String, dynamic>>> fetchAllItems() async {
    final collections = [
      'beverages',
      'dairy&eggs',
      'frozenfoods',
      'grocery',
      'health&wellness',
      'meats&seafoods',
      'snacks',
    ];

    List<Map<String, dynamic>> allItems = [];

    for (var collection in collections) {
      var snapshot = await FirebaseFirestore.instance.collection(collection).get();
      for (var doc in snapshot.docs) {
        allItems.add({
          'id': doc.id,
          'name': doc['productName'], // Adjust field name
          'collection': collection,
          ...doc.data(), // Add other fields if needed
        });
      }
    }

    return allItems;
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = _allItems
          .where((item) =>
              item['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _navigateToItem(String collection, String itemId) {
    switch (collection) {
      case 'beverages':
        Navigator.push(context, MaterialPageRoute(builder: (_) => BeveragesScreen()));
        break;
      case 'snacks':
        Navigator.push(context, MaterialPageRoute(builder: (_) => SnacksPage()));
        break;
      // Add other cases for different collections
      default:
        break;
    }
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
  // Fetch data from Firestore for the different sections
  Future<void> _fetchDeals() async {
    try {
      // Fetch GreenMart Deals
      QuerySnapshot greenMartSnapshot = await FirebaseFirestore.instance
          .collection('greenMartDeals')
          .get();
      setState(() {
        _greenMartDeals = greenMartSnapshot.docs
            .map((doc) => {
                  'productName': doc['productName'],
                  'imageUrl': doc['imageUrl'],
                  'dealType': doc['dealType'],
                  'discount': doc['discount'],
                })
            .toList();
      });

      // Fetch Best Sellers
      QuerySnapshot bestSellersSnapshot = await FirebaseFirestore.instance
          .collection('bestSellers')
          .get();
      setState(() {
        _bestSellers = bestSellersSnapshot.docs
            .map((doc) => {
                  'productName': doc['productName'],
                  'imageUrl': doc['imageUrl'],
                  'price': doc['price'],
                })
            .toList();
      });

      // Fetch Fresco Deals
      QuerySnapshot frescoDealsSnapshot = await FirebaseFirestore.instance
          .collection('frescoDeals')
          .get();
      setState(() {
        _frescoDeals = frescoDealsSnapshot.docs
            .map((doc) => {
                  'productName': doc['productName'],
                  'imageUrl': doc['imageUrl'],
                  'dealType': doc['dealType'],
                  'discount': doc['discount'],
                })
            .toList();
      });
    } catch (e) {
      print('Error fetching deals: $e');
    }
  }

  void _autoScrollImages() {
    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (_imageUrls.isNotEmpty) {
        int nextPage = _currentPage + 1;
        if (nextPage == _imageUrls.length) {
          nextPage = 1;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }
  Future<String> getCurrentUserId() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('current_user')
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    return snapshot.docs.first['userId'];
  } else {
    throw Exception("No current user found.");
  }
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
      case 1: // Categories
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CategoryPage()),
        );
        break;
      case 2: // Settings
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
      case 3: // Profile
        getCurrentUserId().then((userId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationScreen(currentUserId: userId),
      ),
    );
  }).catchError((error) {
    // Handle errors (e.g., show a message or log)
    print("Error fetching currentUserId: $error");
  });
        break;
      case 5: // Shopping Cart
         
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
 Widget SectionItemCard(String productName, String imageUrl, [String? price, String? discount]) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(productName),
              if (price != null) Text('Price: \$${price}'),
              if (discount != null) 
                Container(
                  margin: const EdgeInsets.only(top: 4.0),
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${discount}% OFF',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
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
           //IconButton(
            //  icon: const Icon(Icons.menu, color: Colors.white),
             // onPressed: () {},
          //  ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/logo.png',
              height: 50,
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShoppingCartPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (query) {
                        _filterItems(query); // Filter items as the user types
                      },
                      decoration: InputDecoration(
                        hintText: 'What are you looking for?',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.green.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            // Display filtered items or message if empty
           /* _filteredItems.isEmpty
                ? Center(child: Text('No items found'))
                : ListView.builder(
                shrinkWrap: true, // Ensure the ListView takes only the space it needs
                physics: NeverScrollableScrollPhysics(), // Disable scrolling to avoid conflict with SingleChildScrollView
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text(item['collection']),
                    onTap: () => _navigateToItem(item['collection'], item['id']),
                  );
                },
              ),*/
            // Image carousel with auto-scroll and dots indicator
            SizedBox(
              height: 190,
              width: 400,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35.0), // Adjust the radius for curve effect
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CATEGORIES',
                  style: TextStyle(
                    fontSize: 18,
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
                  CategoryCard('Grocery', 'assets/grocery1.png', GroceryPage(), width: 80, height: 100),
                  CategoryCard('Frozen Foods', 'assets/frozen1.png', FrozonPage(), width: 80, height: 100),
                  CategoryCard('Beverage', 'assets/beverages1.png', BeveragesScreen(), width: 80, height: 100),
                  CategoryCard('Snacks', 'assets/snacks1.jpg', SnacksPage(), width: 80, height: 100),
                  CategoryCard('Meats & Seafood', 'assets/meats1.webp', MeatsSeafoodPage(),width: 100, height: 110),
                  CategoryCard('Health&Wellness', 'assets/health1.png', HealthPage(), width: 100, height: 110),
                  CategoryCard('Bakery Products', 'assets/bakery1.png', BakeryProductsPage(),width: 100, height: 110),
                  CategoryCard('Dairy & Eggs', 'assets/dairy1.png', DairyPage(), width: 80, height: 100),
                ],
              ),
            ),
            // Other sections (Deals, Best Sellers, etc.)
            ...[
              {
                'title': 'GreenMart Deals',
                'products': _greenMartDeals,
                'sectionType': 'greenMartDeals',
              },
             /* {
                'title': 'Best Sellers',
                'products': _bestSellers,
                'sectionType': 'bestSellers',
              },*/
             /* {
                'title': 'Fresco Deals',
                'products': _frescoDeals,
                'sectionType': 'frescoDeals',
              },*/
            ].map((section) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section['title'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: (section['products'] as List).map((product) {
                          return SectionItemCard(
                            product['productName'] as String,
                            product['imageUrl'] as String,
                            product.containsKey('price') ? product['price'] : null,
                            product.containsKey('discount') ? product['discount'] : null,
                          );
                        }).toList(),
                        
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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

class CategoryCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Widget page;
  final double width;
  final double height;

  const CategoryCard(this.title, this.imagePath, this.page,
      {this.width = 120, this.height = 140, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: width,
        height: height,
        child: Column(
          children: [
            Image.asset(imagePath, width: width, height: height * 0.7, fit: BoxFit.cover),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


class SectionItemCard extends StatelessWidget {
  final String productName;
  final String imagePath;

  const SectionItemCard(
    this.productName,
    this.imagePath, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to product details page or add to cart
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(productName),
            ),
          ],
        ),
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

class CustomSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> allItems; // List of all items fetched from Firestore
  final Function(String, String) navigateToItem; // Navigation function

  CustomSearchDelegate({required this.allItems, required this.navigateToItem});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear the search query
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search screen
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildFilteredList(); // Show filtered results
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // If the query is empty, do not show the list
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Type at least one letter to search.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Show filtered suggestions when query is not empty
    return _buildFilteredList();
  }

  Widget _buildFilteredList() {
    // Filter results based on the query
    final results = allItems
        .where((item) =>
            item['name'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No results found.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          title: Text(item['name']),
          subtitle: Text(item['collection']),
          onTap: () => navigateToItem(item['collection'], item['id']),
        );
      },
    );
  }
}


