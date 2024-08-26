import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homescreen.dart'; // Import the HomeScreen class

class EnterSmsCodeScreen extends StatefulWidget {
  final String verificationId;
  final String email;
  final String password;

  EnterSmsCodeScreen({
    required this.verificationId,
    required this.email,
    required this.password,
  });

  @override
  _EnterSmsCodeScreenState createState() => _EnterSmsCodeScreenState();
}

class _EnterSmsCodeScreenState extends State<EnterSmsCodeScreen> {
  final TextEditingController _smsCodeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  void _verifySmsCode() async {
    final String smsCode = _smsCodeController.text.trim();

    if (smsCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the SMS code')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create PhoneAuthCredential with the entered code and verificationId
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      // Sign in the user with the credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Update user's email and password
      await userCredential.user?.updateEmail(widget.email);
      await userCredential.user?.updatePassword(widget.password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up successful!')),
      );

      // Navigate to the HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid SMS code. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter SMS Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please enter the SMS code sent to your phone',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _smsCodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'SMS Code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifySmsCode,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      backgroundColor: Color(0xFF66BB6A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'Verify Code',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
            SizedBox(height: 20),
            Text(
              'Didn\'t receive the code? Please wait or try again later.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
