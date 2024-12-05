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
          _showSnackbar('User not found');
        }
      } else {
        _showSnackbar('Current user not found');
      }
    } catch (e) {
      _showSnackbar('Error fetching user details');
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
        _showSnackbar('No pickup details found for this user');
      }
    } catch (e) {
      _showSnackbar('Error fetching refund option');
    }
  }

  Future<void> _fetchCartTotal() async {
    try {
      DocumentSnapshot cartDoc = await FirebaseFirestore.instance
          .collection('cart')
          .doc(userId)
          .get();

      if (cartDoc.exists) {
        setState(() {
          total = cartDoc.get('totalPrice') ?? 0.0;
        });
      } else {
        _showSnackbar('No cart found for this user');
      }
    } catch (e) {
      _showSnackbar('Error fetching cart total');
    }
  }

  Future<void> _saveTransaction() async {
    try {
      DocumentSnapshot transactionIdSnapshot = await FirebaseFirestore.instance
          .collection('transactionsId')
          .doc('latestId')
          .get();

      int newId = 1;
      if (transactionIdSnapshot.exists) {
        newId = transactionIdSnapshot.get('transactionId') + 1;
      }

      String createdAtDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String createdAtTime = DateFormat('HH:mm:ss').format(DateTime.now());

      String paymentStatus = refundOption == 'CashOnDelivery'
          ? 'Processing'
          : refundOption == 'Online'
              ? 'Paid'
              : 'Unknown';

      List<Map<String, dynamic>> itemsList = await _fetchCartItems();

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc('$newId')
          .set({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'paymentMethod': refundOption,
        'paymentStatus': paymentStatus,
        'amount': total,
        'date': createdAtDate,
        'time': createdAtTime,
        'userId': userId,
        'items': itemsList,
        'createdAt': Timestamp.now(),
      });

      await FirebaseFirestore.instance
          .collection('transactionsId')
          .doc('latestId')
          .set({'transactionId': newId, 'createdAt': FieldValue.serverTimestamp()});

      _showSnackbar('Transaction saved successfully');
      await _clearCart();
    } catch (e) {
      _showSnackbar('Error saving transaction');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCartItems() async {
    try {
      DocumentSnapshot cartDoc = await FirebaseFirestore.instance
          .collection('cart')
          .doc(userId)
          .get();

      if (cartDoc.exists) {
        List<dynamic> items = cartDoc.get('items') ?? [];
        return items.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {}
    return [];
  }

  Future<void> _clearCart() async {
    try {
      DocumentSnapshot cartDoc = await FirebaseFirestore.instance
          .collection('cart')
          .doc(userId)
          .get();

      if (cartDoc.exists) {
        await cartDoc.reference.delete();
      }
      _showSnackbar('Cart cleared successfully');
    } catch (e) {
      _showSnackbar('Error clearing cart');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
              onPressed: () async {
                await _fetchCartTotal();
                await _saveTransaction();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
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
