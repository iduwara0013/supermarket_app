import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for saving details
import 'Delivery.dart'; // Import your Delivery.dart file here
import 'CardPaymentScreen.dart'; // Import CardPaymentScreen

class PickupDetailsScreen extends StatefulWidget {
  final String docId; // Add a field for the document ID

  const PickupDetailsScreen({Key? key, required this.docId}) : super(key: key);

  @override
  _PickupDetailsScreenState createState() => _PickupDetailsScreenState();
}

class _PickupDetailsScreenState extends State<PickupDetailsScreen> {
  String _refundOption = 'Online Payment'; // Default option
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Method to save input details to Firestore
  Future<void> _savePickupDetails() async {
    // Validate form
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _dateTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Use the passed document ID for the PickupDetails
    String docName = widget.docId; // Use the passed document ID

    // Create a map with the input details
    Map<String, dynamic> pickupDetails = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'dateTime': _dateTimeController.text,
      'notes': _notesController.text,
      'refundOption': _refundOption,
    };

    try {
      // Save the pickup details in Firestore
      await FirebaseFirestore.instance.collection('PickupDetails').doc(docName).set(pickupDetails);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pickup details saved successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving pickup details: $e')),
      );
    }
  }

  // Method to handle Next button press
  void _onNextPressed() async {
    await _savePickupDetails(); // Save details before navigating

    if (_refundOption == 'Cash on Delivery') {
      Navigator.push(
            context,
            MaterialPageRoute(
          builder: (context) => DeliveryScreen(docId: 'yourDocId'), // Replace with the actual document ID
        ),
      );

    } else if (_refundOption == 'Online Payment') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CardPaymentScreen(docId: widget.docId)), // Pass docId to CardPaymentScreen
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
                      value: 'Cash on Delivery',
                      groupValue: _refundOption,
                      onChanged: (value) {
                        setState(() {
                          _refundOption = value!;
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
                      value: 'Online Payment',
                      groupValue: _refundOption,
                      onChanged: (value) {
                        setState(() {
                          _refundOption = value!;
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
