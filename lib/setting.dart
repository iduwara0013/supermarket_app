import 'package:flutter/material.dart';
import 'homescreen.dart'; // Import HomeScreen from homescreen.dart
//import 'shopping_cart.dart'; // Import ShoppingCartPage from shopping_cart.dart
import 'category.dart'; // Import CategoryPage from category.dart
//import 'notification.dart'; // Import NotificationPage from notification.dart
import 'profile_information.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 3; // Initialize the selected index to Settings

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the corresponding page based on the index
    if (index == 0) { 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } /*else if (index == 1) { 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ShoppingCartPage()),
      );
    } */else if (index == 2) { 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CategoryPage()),
      );
    } /*else if (index == 4) { 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotificationPage()),
      );
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Account Settings'),
        backgroundColor: Color(0xFF66BB6A),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text('Update your account settings.'),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile Information'),
              subtitle: Text('Change your account details'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileInformationPage()),
                );
                // Handle Profile Information tap
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete Account'),
              subtitle: Text('Delete your account from the app'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Handle Delete Account tap
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              subtitle: Text('Log out of the App'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Handle Logout tap
              },
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

// Reuse the BottomNavBar from the previous code
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
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: onItemTapped,
    );
  }
}
