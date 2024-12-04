import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homescreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _signUp() async {
    try {
      // Create a new user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Show a snackbar indicating that a verification email has been sent
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent! Please check your inbox.')),
      );

      // Save user details in Firestore
      await _saveUserDetails(userCredential.user?.uid ?? '', userCredential.user?.email ?? '');

      // Save userId to current_user collection
      await _saveCurrentUser(userCredential.user?.uid ?? '', userCredential.user?.email ?? '');

      // Optionally, wait for verification
      await _checkEmailVerification();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveUserDetails(String userId, String email) async {
    // Retrieve and increment the current_id from the counters collection
    DocumentReference counterRef = _firestore.collection('counters').doc('user_counter');
    DocumentSnapshot counterDoc = await counterRef.get();

    if (counterDoc.exists) {
      int currentId = counterDoc['current_id'];

      // Increment the current_id
      int newId = currentId + 1;

      // Save the new ID back to the counters collection
      await counterRef.update({'current_id': newId});

      // Save user details in the users collection with the incremented ID as the document ID
      await _firestore.collection('users').doc(newId.toString()).set({
        'userId': newId.toString(), // Use the incremented ID as the userId
        'name': _nameController.text,
        'email': email,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'membershipStatus': 'Not Registered', // Set default membership status
        'createdAt': FieldValue.serverTimestamp(), // Automatically add the createdAt timestamp
      });
    } else {
      throw Exception("Counter document does not exist");
    }
  }

  Future<void> _saveCurrentUser(String userId, String email) async {
    // Fetch user document from 'users' collection using the email
    QuerySnapshot userQuerySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    // Check if any documents were found
    if (userQuerySnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = userQuerySnapshot.docs.first;

      // Save to 'current_user' collection with userId and email
      await _firestore.collection('current_user').doc('current').set({
        'userId': userDoc['userId'], // Use userId from the 'users' document
        'email': email,
      });
    }
  }

  Future<void> _checkEmailVerification() async {
    User? user = _auth.currentUser;

    // Wait for a bit before checking
    await Future.delayed(const Duration(seconds: 5));

    // Ensure user is not null before proceeding
    if (user != null) {
      await user.reload(); // Reload the user to get updated information
      User? updatedUser = _auth.currentUser; // Fetch the updated user instance

      // Check if the updated user is not null and if email is verified
      if (updatedUser != null && updatedUser.emailVerified) {
        // Navigate to HomeScreen if the email is verified
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // If not verified, keep checking
        _checkEmailVerification();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      appBar: AppBar(
        backgroundColor: Colors.white, // Background color of the AppBar
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2B2B2B)), // Back arrow color
          onPressed: () {
            Navigator.pop(context); // Navigate back when tapped
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2B2B), // Darker color for heading
                ),
              ),
              const SizedBox(height: 30),
              Image.asset(
                'assets/OnBoarding.png', // Ensure the image path is correct
                height: 200,
              ),
              const SizedBox(height: 30),
              _buildCustomTextField('Name', _nameController),
              const SizedBox(height: 20),
              _buildCustomTextField('Email', _emailController),
              const SizedBox(height: 20),
              _buildCustomPasswordField(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF6CC51D), // Text color on button
                  padding: const EdgeInsets.symmetric(vertical: 16), // Adjusts padding inside button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  ),
                  minimumSize: const Size(double.infinity, 50), // Minimum size for the button (width, height)
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF888888), // Subtle color for the text field labels
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5), // Light gray background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          borderSide: BorderSide.none, // No border
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Padding inside the text field
      ),
    );
  }

  Widget _buildCustomPasswordField() {
  return TextFormField(
    controller: _passwordController,
    obscureText: !_passwordVisible,
    maxLength: 8,  // Limit password to exactly 8 characters
    decoration: InputDecoration(
      labelText: 'Password',
      labelStyle: const TextStyle(
        color: Color(0xFF888888),
        fontWeight: FontWeight.bold,
      ),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      suffixIcon: IconButton(
        icon: Icon(
          _passwordVisible ? Icons.visibility : Icons.visibility_off,
          color: const Color(0xFF888888),
        ),
        onPressed: () {
          setState(() {
            _passwordVisible = !_passwordVisible;
          });
        },
      ),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Password cannot be empty';
      }

      // Ensure the password has exactly 8 characters
      if (value.length != 8) {
        return 'Password must be exactly 8 characters long';
      }

      // Regular expression for password validation: At least 1 uppercase, 1 lowercase, 1 digit, and 1 special character
      RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8}$');

      if (!passwordRegExp.hasMatch(value)) {
        return 'Password must contain uppercase, lowercase, number, and symbol';
      }

      return null;  // Return null if valid
    },
  );
}


}