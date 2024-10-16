import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Delivery.dart'; // Import your Delivery screen

class CardPaymentScreen extends StatefulWidget {
  final String docId; // Accept docId as a parameter

  CardPaymentScreen({required this.docId});

  @override
  _CardPaymentScreenState createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final _formKey = GlobalKey<FormState>(); // Global key for form
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _saveCard = false;
  String _selectedPaymentMethod = 'Debit/Credit Card';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: const Color(0xFF4CAF50),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign the form key here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select your mode of payment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildPaymentOption('Debit/Credit Card', true),
              _buildPaymentOption('GPay', false),
              _buildPaymentOption('PayPal', false),
              _buildPaymentOption('Cash on Delivery', false),
              const SizedBox(height: 20),
              if (_selectedPaymentMethod == 'Debit/Credit Card')
                _buildCardDetailsForm(),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text('Save Card Details for Future Use'),
                value: _saveCard,
                onChanged: (value) {
                  setState(() {
                    _saveCard = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm, // Handle form submission
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Pay Now', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String method, bool isSelected) {
    return ListTile(
      leading: Radio<String>(
        value: method,
        groupValue: _selectedPaymentMethod,
        onChanged: (value) {
          setState(() {
            _selectedPaymentMethod = value!;
          });
        },
      ),
      title: Text(method),
    );
  }

  Widget _buildCardDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Card Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _cardNameController,
          decoration: const InputDecoration(
            labelText: 'Name on Card',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the name on the card';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _cardNumberController,
          decoration: const InputDecoration(
            labelText: 'Card Number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          maxLength: 16,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the card number';
            } else if (value.length != 16) {
              return 'Card number must be 16 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: 'Expiration Date (MM/YY)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter expiration date';
                  } else if (!_validateExpiryDate(value)) {
                    return 'Invalid date';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter CVV';
                  } else if (value.length != 3) {
                    return 'CVV must be 3 digits';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Form submission function
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // If all fields are valid, proceed with payment logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Payment')),
      );

      // Save payment details to Firestore
      _addPaymentDetails().then((_) {
        // Navigate to Delivery.dart after successful payment
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DeliveryScreen(docId: '',)), // Replace with your Delivery screen widget
        );
      });

      if (_saveCard) {
        _saveCardDetails();
      }
    }
  }

  // Save payment details to Firestore
  Future<void> _addPaymentDetails() async {
    try {
      await FirebaseFirestore.instance.collection('payment').add({
        'paymentName': 'Your Payment Name', // Replace with the actual payment name
        'payAmount': 100.0, // Replace with the actual amount you want to save
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment details saved successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save payment details: $error')),
      );
    }
  }

  // Save card details to Firestore
  void _saveCardDetails() {
    FirebaseFirestore.instance.collection('cart').doc(widget.docId).update({
      'cardDetails': {
        'cardNumber': _cardNumberController.text,
        'expiryDate': _expiryDateController.text,
        'cvv': _cvvController.text,
      }
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card details saved successfully!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save card details: $error')),
      );
    });
  }

  // Expiry date validation
  bool _validateExpiryDate(String value) {
    final RegExp expiryRegExp = RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$');
    return expiryRegExp.hasMatch(value);
  }
}
