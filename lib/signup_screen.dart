import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication package
import 'homescreen.dart'; // Import the HomeScreen class

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _newsletter = false;

  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Authentication instance

  void _signUp() async {
  final String name = _nameController.text.trim();
  final String email = _emailController.text.trim();
  final String password = _passwordController.text.trim();

  if (name.isEmpty || email.isEmpty || password.isEmpty) {
    // Display an error message if any field is empty
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill out all fields')),
    );
    return;
  }

  try {
    // Create a new user with Firebase Authentication
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update the user profile with the display name
    await userCredential.user!.updateProfile(displayName: name);
    await userCredential.user!.reload(); // Reload to ensure the updated profile is fetched

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sign up successful!')),
    );

    // Optionally, you can clear the fields after a successful sign up
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _newsletter = false;
      _passwordVisible = false;
    });

    // Navigate to the HomeScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );

  } catch (e) {
    // Handle Firebase Authentication errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to sign up: ${e.toString()}')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: Color(0x1A66BB6A), // Light fill color with low opacity (10%)
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFF66BB6A), // Green color for border
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFF66BB6A), // Green color for focused state
                      width: 2.0, // Thicker border when focused
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Color(0x1A66BB6A), // Light fill color with low opacity (10%)
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFF66BB6A), // Green color for border
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFF66BB6A), // Green color for focused state
                      width: 2.0, // Thicker border when focused
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Color(0x1A66BB6A), // Light fill color with low opacity (10%)
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFF66BB6A), // Green color for border
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFF66BB6A), // Green color for focused state
                      width: 2.0, // Thicker border when focused
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_passwordVisible,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _newsletter,
                    onChanged: (bool? value) {
                      setState(() {
                        _newsletter = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'I would like to receive your newsletter and other promotional information',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp, // Call the _signUp method
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                  backgroundColor: Color(0xFF66BB6A), // Green color matching the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              
            ],
          ),
        ),
      ),
    );
  }
}
