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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _saveCard = false;
  String _selectedPaymentMethod = 'Debit/Credit Card';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              _buildPaymentOptions(),
              const SizedBox(height: 20),
              if (_selectedPaymentMethod == 'Debit/Credit Card')
                _buildCardDetailsForm(),
              const SizedBox(height: 20),
              _buildSaveCardCheckbox(),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOptions() {
    final options = [
      'Debit/Credit Card',
      'GPay',
      'PayPal',
      'Cash on Delivery',
    ];

    return Column(
      children: options.map((method) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = method;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: _selectedPaymentMethod == method
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _selectedPaymentMethod == method
                    ? const Color(0xFF4CAF50)
                    : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: method,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                  activeColor: const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 10),
                Text(
                  method,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCardDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _cardNameController,
          labelText: 'Name on Card',
          hintText: 'Enter the name on your card',
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _cardNumberController,
          labelText: 'Card Number',
          hintText: 'XXXX XXXX XXXX XXXX',
          maxLength: 16,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _expiryDateController,
                labelText: 'Expiration Date',
                hintText: 'MM/YY',
                keyboardType: TextInputType.datetime,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                controller: _cvvController,
                labelText: 'CVV',
                hintText: '123',
                maxLength: 3,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
        counterText: '',
      ),
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
    );
  }

  Widget _buildSaveCardCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _saveCard,
          onChanged: (value) {
            setState(() {
              _saveCard = value!;
            });
          },
          activeColor: const Color(0xFF4CAF50),
        ),
        const Text(
          'Save Card Details for Future Use',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Payment...')),
      );

      _addPaymentDetails().then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DeliveryScreen()),
        );
      });

      if (_saveCard) {
        _saveCardDetails();
      }
    }
  }

  Future<void> _addPaymentDetails() async {
    try {
      await FirebaseFirestore.instance.collection('payment').add({
        'paymentName': 'Payment',
        'payAmount': 100.0,
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
}
