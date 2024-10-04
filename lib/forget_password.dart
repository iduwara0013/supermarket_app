import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'changepassword.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _sendOtp() async {
    final String email = _emailController.text.trim();

    try {
      // Send password reset email (This acts as an OTP sender in Firebase's case)
      await _auth.sendPasswordResetEmail(email: email);

      setState(() {
        _otpSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to $email'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
        ),
      );
    }
  }

  void _verifyOtp() {
    final String otp = _otpController.text.trim();
    
    // Since Firebase doesn't use OTP directly, you'll typically verify with the email link
    // In this case, you'd be validating the email reset link
    // For demo purposes, let's assume OTP is correct and navigate to the next screen
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChangePasswordScreen(email: _emailController.text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child : Center(
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_otpSent)
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _otpSent ? _verifyOtp : _sendOtp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(
                _otpSent ? 'Verify OTP' : 'Send OTP',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
