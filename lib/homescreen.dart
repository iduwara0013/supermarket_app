import 'package:flutter/material.dart';
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
import 'fresco_registration.dart'; // Import the Fresco Registration page
import 'snacks.dart';

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

  final List<String> _imagePaths = [
    'assets/promotion.jpg',
    'assets/promotion2.jpg',
    'assets/promotion3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _autoScrollImages();
  }

  void _autoScrollImages() {
    Future.delayed(const Duration(seconds: 3)).then((_) {
      int nextPage = _currentPage + 1;
      if (nextPage == _imagePaths.length) {
        nextPage = 0;
      }
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CategoryPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    } else {
      // Handle other navigation items if necessary
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
                          itemCount: _imagePaths.length,
                          itemBuilder: (context, index) {
                            return Image.asset(
                              _imagePaths[index],
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
                              dotsCount: _imagePaths.length,
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
                      fontSize: 20,
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
                    CategoryCard('Frozen Foods', 'assets/frozen1.png', const FrozonPage()),
                    CategoryCard('Beverage', 'assets/beverages1.png', BeveragesScreen()),
                    CategoryCard('Snacks', 'assets/snacks1.png', SnacksPage()),
                    CategoryCard('Meats & Seafood', 'assets/meats1.png', null),
                    CategoryCard('Health & Wellness', 'assets/health1.png', null),
                    CategoryCard('Bakery Products', 'assets/bakery1.png', null),
                    CategoryCard('Dairy & Eggs', 'assets/dairy1.png', const DairyPage()),
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
                    )
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green,
          onTap: _onItemTapped,
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
