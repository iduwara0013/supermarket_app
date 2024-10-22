import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homescreen.dart'; // Assuming you have a HomeScreen defined in this file

class FrescoRegistration extends StatefulWidget {
  const FrescoRegistration({super.key});

  @override
  _FrescoRegistrationState createState() => _FrescoRegistrationState();
}

class _FrescoRegistrationState extends State<FrescoRegistration> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _agreeTerms = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdFromUsersCollection();
  }

  // Step 1: Load userId from the 'users' collection in Firestore
  Future<void> _loadUserIdFromUsersCollection() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Fetch the user document from the 'users' collection using the userId
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (userDoc.docs.isNotEmpty) {
          // User is registered in 'users' collection
          _userId = userDoc.docs.first.id; // Document ID is the userId
          var userData = userDoc.docs.first.data();

          // Populate the form fields with existing data
          _firstNameController.text = userData['firstName'] ?? '';
          _lastNameController.text = userData['lastName'] ?? '';
          _emailController.text = userData['email'] ?? user.email!;
          _phoneController.text = userData['phone'] ?? '';
          _nicController.text = userData['nic'] ?? '';
          _addressController.text = userData['address'] ?? '';
        } else {
          // No user found in 'users' collection
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found in users collection')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No logged-in user found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A6810),
        title: const Text('Fresco Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset('assets/fresco_logo.png'), // Placeholder for the Fresco logo
            ),
            const SizedBox(height: 30),
            _buildTextField(_firstNameController, 'First Name'),
            const SizedBox(height: 20),
            _buildTextField(_lastNameController, 'Last Name'),
            const SizedBox(height: 20),
            _buildTextField(_emailController, 'Email'),
            const SizedBox(height: 20),
            _buildTextField(_phoneController, 'Phone No'),
            const SizedBox(height: 20),
            _buildTextField(_nicController, 'NIC No'),
            const SizedBox(height: 20),
            _buildTextField(_addressController, 'Address'),
            const SizedBox(height: 20),
            CheckboxListTile(
              value: _agreeTerms,
              onChanged: (bool? value) {
                setState(() {
                  _agreeTerms = value ?? false;
                });
              },
              title: const Text("I agree with the terms and condition"),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _agreeTerms ? _register : null, // Register button is enabled only if terms are agreed
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Register', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  // Step 2: Register the user and update the membership status
  void _register() async {
    if (_userId != null) {
      try {
        // Save registration details to the 'Fresco_Registration' collection with the userId as the document ID
        await FirebaseFirestore.instance
            .collection('Fresco_Registration')
            .doc(_userId)
            .set({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'nic': _nicController.text,
          'address': _addressController.text,
          'userId': _userId, // Save the userId
        });

        // Update the 'membership' field in the 'users' collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .update({'membership': 'Active'});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );

        // Navigate to the HomeScreen after registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving registration details: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user ID found. Please ensure you are registered.')),
      );
    }
  }
}
