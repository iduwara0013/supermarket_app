import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification.dart';
import 'homescreen.dart';
import 'category.dart';
import 'profile_information.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
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
class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 2; // Default selected index for Settings
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on index
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CategoryPage()),
        );
        break;
      case 2:
        break; // Stay on the current page (Settings)
      case 3:
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
    }
  }

  Future<void> _deleteAccount() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        DocumentSnapshot currentUserDoc = await _firestore
            .collection('current_user')
            .doc('current')
            .get();

        if (currentUserDoc.exists) {
          final data = currentUserDoc.data() as Map<String, dynamic>?;
          final userId = data?['userId'] ?? '';

          if (userId.isNotEmpty) {
            await _firestore.collection('users').doc(userId).delete();
            await currentUser.delete();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account deleted successfully.')),
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const GreenMarketScreen()),
              (route) => false,
            );
          } else {
            _showError('User ID not found.');
          }
        } else {
          _showError('No current user document found.');
        }
      }
    } catch (e) {
      _showError('Failed to delete account: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirm', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout() {
    _showConfirmationDialog(
      title: 'Logout',
      content: 'Are you sure you want to log out?',
      onConfirm: () {
        _auth.signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
    );
  }

  void _confirmDeleteAccount() {
    _showConfirmationDialog(
      title: 'Delete Account',
      content: 'Are you sure you want to delete your account? This action cannot be undone.',
      onConfirm: _deleteAccount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: const Color(0xFF66BB6A),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update your account settings.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.grey),
              title: const Text('Profile Information'),
              subtitle: const Text('Change your account details'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileInformationPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.grey),
              title: const Text('Delete Account'),
              subtitle: const Text('Delete your account from the app'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: _confirmDeleteAccount,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey),
              title: const Text('Logout'),
              subtitle: const Text('Log out of the App'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: _confirmLogout,
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
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notification'),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: onItemTapped,
    );
  }
}
