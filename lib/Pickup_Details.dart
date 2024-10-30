import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Delivery.dart'; // Import your Delivery.dart file here
import 'CardPaymentScreen.dart'; // Import CardPaymentScreen

class PickupDetailsScreen extends StatefulWidget {
  const PickupDetailsScreen({Key? key}) : super(key: key);

  @override
  _PickupDetailsScreenState createState() => _PickupDetailsScreenState();
}

class _PickupDetailsScreenState extends State<PickupDetailsScreen> {
  String _refundOption = 'Online Payment'; // Default option
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _userId; // Store userId from 'current_user' collection

  @override
  void initState() {
    super.initState();
    _fetchUserIdAndDetails();
  }

  // Fetch userId from the 'current_user' collection and user details from the 'users' collection
  Future<void> _fetchUserIdAndDetails() async {
    try {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('current_user')
          .doc('current')
          .get();
      if (currentUserDoc.exists) {
        _userId = currentUserDoc.data()?['userId']; // Fetch userId
        _loadUserDetails(_userId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: $e')),
      );
    }
  }

  // Load user details from the 'users' collection
  Future<void> _loadUserDetails(String? userId) async {
    if (userId != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          var userData = userDoc.data();
          _nameController.text = userData?['name'] ?? ''; // Assuming name field exists
          _phoneController.text = userData?['phone'] ?? ''; // Assuming phone field exists
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found in users collection')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    }
  }

  // Method to save input details to Firestore using userId as document ID
  Future<void> _savePickupDetails() async {
    // Validate form
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _dateTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Ensure _userId is fetched before trying to save
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
      return;
    }

    // Use the fetched _userId as the document ID
    String docId = _userId!; // This will set the document ID to the user's ID

    // Create a map with the input details
    Map<String, dynamic> pickupDetails = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'dateTime': _dateTimeController.text,
      'notes': _notesController.text,
      'refundOption': _refundOption,
      'userId': _userId, // Save the userId
    };

    try {
      // Save the pickup details in Firestore with userId as the document ID
      await FirebaseFirestore.instance
          .collection('PickupDetails')
          .doc(docId)
          .set(pickupDetails);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pickup details saved successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving pickup details: $e')),
      );
      print('Error saving pickup details: $e'); // Log error for debugging
    }
  }

  // Method to handle Next button press
  void _onNextPressed() async {
    await _savePickupDetails(); // Save details before navigating

    // Navigate to the appropriate screen based on refund option
    if (_refundOption == 'Online') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CardPaymentScreen(docId: _userId!), // Pass docId
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeliveryScreen(), // Navigate to DeliveryScreen
        ),
      );
    }
  }

  // Method to open the Date Picker and set the date & time
  Future<void> _selectDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _dateTimeController.text =
              "${pickedDate.toLocal()}".split(' ')[0] + " " + pickedTime.format(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Details'),
        backgroundColor: const Color(0xFF4CAF50),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Middle Image
            Image.asset(
              'assets/pickup_image.png',
              height: 100,
            ),
            const SizedBox(height: 10),
            const Text(
              "Please enter collector's name, phone number and a convenient date and time for the pickup",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone No',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dateTimeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Date & Time',
                border: OutlineInputBorder(),
              ),
              onTap: _selectDateTime, // Open Date & Time picker when tapped
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Please select your preferred refund option',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: 'CashOnDelivery',
                      groupValue: _refundOption,
                      onChanged: (value) {
                        setState(() {
                          _refundOption = value!; // Update refund option
                        });
                      },
                    ),
                    const Icon(Icons.monetization_on, color: Colors.black),
                    const Text('Cash on Delivery'),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Online',
                      groupValue: _refundOption,
                      onChanged: (value) {
                        setState(() {
                          _refundOption = value!; // Update refund option
                        });
                      },
                    ),
                    const Icon(Icons.credit_card, color: Colors.black),
                    const Text('Online Payment'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: _onNextPressed,
              child: const Text('Next', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
