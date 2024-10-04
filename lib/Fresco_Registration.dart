import 'package:flutter/material.dart';

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

  void _register() {
    // Handle the registration logic here
    print('Register button pressed');
  }
}
