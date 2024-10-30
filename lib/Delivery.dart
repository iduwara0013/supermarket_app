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

  double total = 0.0;  // This will store totalPrice from cart
  String refundOption = '';  // This will store refundOption from PickupDetails
  String userId = '';  // To store the userId

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  // Fetch user details and refundOption from PickupDetails
  Future<void> _fetchUserDetails() async {
    try {
      // Get the current user document from the 'current_user' collection
      DocumentSnapshot currentUserSnapshot = await FirebaseFirestore.instance
          .collection('current_user')
          .doc('current')
          .get();

      if (currentUserSnapshot.exists) {
        // Retrieve the userId from the current user document
        userId = currentUserSnapshot.get('userId');

        // Fetch the user's details from the 'users' collection
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

          // Fetch the refundOption from the PickupDetails collection
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

  // Fetch refundOption based on userId from PickupDetails
  Future<void> _fetchRefundOption(String userId) async {
    try {
      // Get the PickupDetails document for the current user
      QuerySnapshot pickupDetailsSnapshot = await FirebaseFirestore.instance
          .collection('PickupDetails')
          .where('userId', isEqualTo: userId)
          .get();

      if (pickupDetailsSnapshot.docs.isNotEmpty) {
        // If a document is found, set the refundOption
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

  // Fetch total price from the cart collection where the document ID is equal to userId
  Future<void> _fetchCartTotal() async {
    try {
      // Fetch the cart document where the ID is the same as userId
      DocumentSnapshot cartDoc = await FirebaseFirestore.instance
          .collection('cart')
          .doc(userId)
          .get();

      if (cartDoc.exists) {
        setState(() {
          total = cartDoc.get('totalPrice') ?? 0.0;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cart found for this user')),
        );
      }
    } catch (e) {
      print('Error fetching cart total: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching cart total: ${e.toString()}')),
      );
    }
  }

  // Save the transaction in the transactions collection
  Future<void> _saveTransaction() async {
    try {
      // Fetch the latest transaction ID from the 'transactionsId' collection
      DocumentSnapshot transactionIdSnapshot = await FirebaseFirestore.instance
          .collection('transactionsId')
          .doc('latestId')
          .get();

      int newId = 1; // Default to 1 if no ID exists yet

      if (transactionIdSnapshot.exists) {
        // If the document exists, get the current transactionId and increment it
        newId = transactionIdSnapshot.get('transactionId') + 1;
      }

      String createdAtDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String createdAtTime = DateFormat('HH:mm:ss').format(DateTime.now());

      // Determine the payment status based on the refundOption
      String paymentStatus;
      if (refundOption == 'CashOnDelivery') {
        paymentStatus = 'Processing';
      } else if (refundOption == 'Online') {
        paymentStatus = 'Paid';
      } else {
        paymentStatus = 'Unknown';  // Default case if needed
      }

      // Fetch cart items and store them in a list
      List<Map<String, dynamic>> itemsList = await _fetchCartItems();

      // Save the transaction document with the itemsList
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc('$newId')
          .set({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'paymentMethod': refundOption,  // Save refundOption as payment method
        'paymentStatus': paymentStatus,  // New field for payment status
        'amount': total,  // Save the totalPrice fetched from cart
        'date': createdAtDate,
        'time': createdAtTime,
        'userId': userId,
        'items': itemsList,  // Save items as a list of maps
      });

      // Update the 'transactionsId' collection with the new transactionId
      await FirebaseFirestore.instance
          .collection('transactionsId')
          .doc('latestId')
          .set({
        'transactionId': newId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction saved successfully')),
      );

      // Clear the user's cart after saving the transaction
      await _clearCart();

      print('Transaction ID: $newId');
    } catch (e) {
      print('Error saving transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving transaction: ${e.toString()}')),
      );
    }
  }

  // Fetch cart items from the cart collection
  Future<List<Map<String, dynamic>>> _fetchCartItems() async {
    try {
      DocumentSnapshot cartDoc = await FirebaseFirestore.instance
          .collection('cart')
          .doc(userId)
          .get();

      if (cartDoc.exists) {
        // Assuming the items are stored in a field called 'items'
        List<dynamic> items = cartDoc.get('items') ?? [];  // Get items as a list

        // Convert the dynamic list to a list of maps
        return items.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print('Error fetching cart items: $e');
    }
    return [];  // Return an empty list if there's an error
  }

  // Clear the user's cart
  Future<void> _clearCart() async {
    try {
      DocumentSnapshot cartDoc = await FirebaseFirestore.instance
          .collection('cart')
          .doc(userId)
          .get();

      if (cartDoc.exists) {
        await cartDoc.reference.delete(); // Deletes the cart document
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
                      MaterialPageRoute(builder: (context) => const MyApp()),
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
