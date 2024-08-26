import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forget_password.dart'; // Ensure the path is correct
import 'homescreen.dart'; // Ensure this is the correct path to your HomeScreen file

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Authentication instance

  void _login() async {
    final String email = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      // Sign in using Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If sign-in is successful, navigate to the HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      // Handle any errors that occur during the sign-in process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging in: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Ensures the button takes full width
            children: [
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center, // Center text
              ),
              SizedBox(height: 30),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Color(0x1A66BB6A), // Light fill color with low opacity (10%)
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0), // Rounded corners
                    borderSide: BorderSide(
                      color: Color(0xFF66BB6A), // Green color for border
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
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
                    borderRadius: BorderRadius.circular(10.0), // Rounded corners
                    borderSide: BorderSide(
                      color: Color(0xFF66BB6A), // Green color for border
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
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
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 80,vertical: 15),
                  backgroundColor: Color(0xFF66BB6A),  // Using the requested color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),  // Rounded button shape
                  ),
                ),
                child: Text(
                  'Log In',
                  style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgetPasswordScreen()),
                  );
                },
                child: Text(
                  'Forgot your password?',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
