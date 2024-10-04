import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeliveryScreen extends StatefulWidget {
  final String docId; // Added docId as a parameter

  const DeliveryScreen({super.key, required this.docId}); // Constructor to accept docId

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  String _selectedAddressType = 'Home'; // Default selected option
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  // Placeholder for the DateTime and refund option
  DateTime? dateTime; // You can fetch this based on your logic
  String refundOption = ''; // Assign a default or fetched value
  double total = 0.0; // Placeholder for the total amount

  @override
  void initState() {
    super.initState();
    _fetchPickupDetails(widget.docId); // Pass the docId to fetch details
  }

  Future<void> _fetchPickupDetails(String docId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('PickupDetails')
          .doc(docId) // Use the passed docId
          .get();

      if (snapshot.exists) {
        setState(() {
          _nameController.text = snapshot.get('name') ?? ''; // Fetches the 'name' field
          _phoneController.text = snapshot.get('phone') ?? ''; // Fetches the 'phone' field
          _addressController.text = snapshot.get('address') ?? ''; // Fetches the 'address' field
          dateTime = snapshot.get('dateTime').toDate(); // Fetch DateTime
          refundOption = snapshot.get('refundOption') ?? ''; // Fetch refund option
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pickup details not found')),
        );
      }
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchCartTotal() async {
    try {
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .get();

      // Assuming you're only interested in the first document's total field
      if (cartSnapshot.docs.isNotEmpty) {
        setState(() {
          total = cartSnapshot.docs[0].get('total') ?? 0.0; // Fetches the total field
        });
      }
    } catch (e) {
      print('Error fetching cart total: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching cart total: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveTransaction() async {
    try {
      // Fetch the current maximum transaction ID
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .orderBy(FieldPath.documentId)
          .get();

      int newId = querySnapshot.docs.length + 1; // Calculate new ID

      // Divide the createdAt timestamp into date and time
      String createdAtDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String createdAtTime = DateFormat('HH:mm:ss').format(DateTime.now());

      // Create a new document in the transactions collection
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc('$newId') // Use newId as the document ID
          .set({
        'name': _nameController.text, // Name field
        'phone': _phoneController.text, // Phone number field
        'address': _addressController.text, // Address field
        'paymentMethod': refundOption, // Refund option from PickupDetails
        'addressType': _selectedAddressType, // Address type (Home/Office)
        'amount': total, // Total amount fetched from the cart
        'date': createdAtDate, // Date when the transaction was created
        'time': createdAtTime, // Time when the transaction was created
       
      });

      // Save the transaction ID in the transactionsId collection
      await FirebaseFirestore.instance
          .collection('transactionsId')
          .doc('$newId') // Using newId as the document ID
          .set({
        'transactionId': newId,
        'createdAt': FieldValue.serverTimestamp(), // To keep track of creation time
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction saved successfully')),
      );

      print('Transaction ID: $newId'); // Print the newly created transaction ID

    } catch (e) {
      print('Error saving transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving transaction: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Delivery'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(
              'assets/pickup_image.png', // Replace with your image asset path
              height: 100,
            ),
            const SizedBox(height: 20),
            _buildEditableTextField('Name', _nameController),
            _buildEditableTextField('Phone No', _phoneController),
            _buildEditableTextField('Address', _addressController),
            const SizedBox(height: 10),
            const Text(
              'Address type',
              style: TextStyle(fontSize: 14),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAddressTypeOption('Home'),
                _buildAddressTypeOption('Office'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {
                _fetchCartTotal().then((_) => _saveTransaction()); // Fetch total and then save transaction
              },
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildAddressTypeOption(String label) {
    return Row(
      children: [
        Radio<String>(
          value: label,
          groupValue: _selectedAddressType,
          onChanged: (String? value) {
            setState(() {
              _selectedAddressType = value!; // Update the selected address type
            });
          },
        ),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
