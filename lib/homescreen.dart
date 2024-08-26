import 'package:flutter/material.dart';
import 'package:my_first_app/cleaning.dart';
import 'dairy.dart'; // Import the DairyPage from dairy.dart
import 'beverage.dart'; // Import the BeveragePage from beverage.dart
import 'package:dots_indicator/dots_indicator.dart'; // Add dots indicator package
import 'frozen.dart';
import 'shopping_cart.dart'; // Import the ShoppingCartPage from shopping_cart.dart
import 'setting.dart'; // Import the SettingsPage from setting.dart
import 'category.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
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
  ]; // Add your image paths here

  @override
  void initState() {
    super.initState();
    _autoScrollImages();
  }

  void _autoScrollImages() {
    Future.delayed(Duration(seconds: 3)).then((_) {
      int nextPage = _currentPage + 1;
      if (nextPage == _imagePaths.length) {
        nextPage = 0;
      }
      _pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 2) { // When Settings icon is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CategoryPage()),
      );
    }
    else if (index == 3) { // When Settings icon is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Green Mart', style: TextStyle(fontSize: 20)),
            Row(
              children: [
                Text('RS.00.00', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShoppingCartPage()),
                    );
                  },
                  child: Icon(Icons.shopping_cart),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.notifications),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'What are you looking for',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.qr_code_scanner, size: 28),
                ],
              ),
            ),
            // Delivery location text
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey),
                  SizedBox(width: 5),
                  Text('Deliver to home', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            // Image carousel with auto-scroll and dots indicator
            Container(
              height: 200, // Set the height to 200 pixels
              width: double.infinity, // Set the width to the screen width
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
                        position: _currentPage,
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
            // Categories Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'CATEGORIES',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              physics: NeverScrollableScrollPhysics(),
              children: [
                CategoryCard('Cleaning', 'assets/cleaning.jpg', CleaningPage()),
                CategoryCard('Frozen', 'assets/frozen.jpg', FrozonPage()),
                CategoryCard('Beverage', 'assets/Beverage.jpeg', BeveragePage()), // Navigate to BeveragePage
                CategoryCard('Snacks', 'assets/snacks.jpg', null),
                CategoryCard('Beauty', 'assets/beauty.jpg', null),
                CategoryCard('Chilled', 'assets/chilled.jpg', null),
                CategoryCard('Dairy', 'assets/dairy.jpg', DairyPage()), // Navigate to DairyPage
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Widget? targetPage;

  CategoryCard(this.title, this.imagePath, this.targetPage);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: targetPage != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => targetPage!),
              );
            }
          : null,
      child: Card(
        child: Column(
          children: [
            Image.asset(imagePath, height: 80, width: 80, fit: BoxFit.cover),
            SizedBox(height: 8),
            Text(title)
          ],
        ),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

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
      selectedItemColor: Color.fromARGB(255, 75, 171, 78),
      unselectedItemColor: Colors.grey,
      onTap: onItemTapped,
    );
  }
}
