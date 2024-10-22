import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'homescreen.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  double total = 0.0;
  String refundOption = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      DocumentSnapshot currentUserSnapshot = await FirebaseFirestore.instance
          .collection('current_user')
          .doc('current')
          .get();

      if (currentUserSnapshot.exists) {
        userId = currentUserSnapshot.get('userId');

        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userSnapshot.exists) {
          setState(() {
            _nameController.text = userSnapshot.get('name') ?? '';
            _phoneController.text = userSnapshot.get('phone') ?? '';
            _addressController.text = userSnapshot.get('address') ?? '';
          });
          _fetchRefundOption(userId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current user not found')),
        );
      }
    } catch (e) {
      print('Error fetching user details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchRefundOption(String userId) async {
    try {
      QuerySnapshot pickupDetailsSnapshot = await FirebaseFirestore.instance
          .collection('PickupDetails')
          .where('userId', isEqualTo: userId)
          .get();

      if (pickupDetailsSnapshot.docs.isNotEmpty) {
        setState(() {
          refundOption = pickupDetailsSnapshot.docs[0].get('refundOption') ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pickup details found for this user')),
        );
      }
    } catch (e) {
      print('Error fetching refund option: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching refund option: ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchCartTotal() async {
    try {
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .get();

      if (cartSnapshot.docs.isNotEmpty) {
        setState(() {
          total = cartSnapshot.docs[0].get('totalPrice') ?? 0.0;
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
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .orderBy(FieldPath.documentId)
          .get();

      int newId = querySnapshot.docs.length + 1;

      String createdAtDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String createdAtTime = DateFormat('HH:mm:ss').format(DateTime.now());

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc('$newId')
          .set({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'paymentMethod': refundOption,
        'amount': total,
        'date': createdAtDate,
        'time': createdAtTime,
        'userId': userId,
      });

      await FirebaseFirestore.instance
          .collection('transactionsId')
          .doc('$newId')
          .set({
        'transactionId': newId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction saved successfully')),
      );

      // After saving the transaction, clear the user's cart
      await _clearCart();

      print('Transaction ID: $newId');
    } catch (e) {
      print('Error saving transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving transaction: ${e.toString()}')),
      );
    }
  }

  Future<void> _clearCart() async {
    try {
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .get();

      for (DocumentSnapshot doc in cartSnapshot.docs) {
        await doc.reference.delete(); // Deletes each document from the cart collection
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart cleared successfully')),
      );
    } catch (e) {
      print('Error clearing cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing cart: ${e.toString()}')),
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
              'assets/pickup_image.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            _buildEditableTextField('Name', _nameController),
            _buildEditableTextField('Phone No', _phoneController),
            _buildEditableTextField('Address', _addressController),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {
                _fetchCartTotal().then((_) {
                  _saveTransaction().then((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
                  });
                });
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
}
