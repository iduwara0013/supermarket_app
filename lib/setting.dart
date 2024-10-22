import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homescreen.dart';
import 'category.dart';
import 'profile_information.dart';
import 'login_screen.dart'; // Import the login_screen.dart for navigation to the login screen

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 3; // Initialize the selected index to Settings
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CategoryPage()),
      );
    }
  }

  // Method to delete the account from Firestore and Firebase Authentication
  Future<void> _deleteAccount() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Fetch the user document from Firestore based on the current user's UID
        DocumentSnapshot userDoc = await _firestore
            .collection('current_user')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          // Get the email and other necessary data from the Firestore document
          String email = userDoc['email']; // Assuming email field is in the Firestore document

          // Delete the document in Firestore (from both current_user and users collection)
          await _firestore.collection('current_user').doc(currentUser.uid).delete();
          await _firestore.collection('users').doc(currentUser.uid).delete();

          // Delete the user from Firebase Authentication
          await currentUser.delete();

          // Show a confirmation message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully.')),
          );

          // Navigate to login screen after deleting the account
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User document does not exist in Firestore.')),
          );
        }
      }
    } catch (e) {
      // Handle errors (such as re-authentication required for account deletion)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change background color to white
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: const Color(0xFF66BB6A), // Keep the green color for the AppBar
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // White back arrow
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8), // Adjusted spacing
            const Text('Update your account settings.'),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.grey), // Outlined person icon
              title: const Text('Profile Information', style: TextStyle(color: Colors.black)),
              subtitle: const Text('Change your account details', style: TextStyle(color: Colors.grey)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey), // Arrow in grey
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileInformationPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.grey), // Outlined delete icon
              title: const Text('Delete Account', style: TextStyle(color: Colors.black)),
              subtitle: const Text('Delete your account from the app', style: TextStyle(color: Colors.grey)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey), // Arrow in grey
              onTap: _deleteAccount, // Call the delete account method when tapped
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey), // Standard logout icon
              title: const Text('Logout', style: TextStyle(color: Colors.black)),
              subtitle: const Text('Log out of the App', style: TextStyle(color: Colors.grey)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey), // Arrow in grey
              onTap: () {
                // Navigate back to the login screen on logout
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
