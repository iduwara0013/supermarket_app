import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // Import image picker
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase storage
import 'dart:io';
import 'Fresco_Registration.dart'; // Import the new registration page

class ProfileInformationPage extends StatefulWidget {
  const ProfileInformationPage({super.key});

  @override
  _ProfileInformationPageState createState() => _ProfileInformationPageState();
}

class _ProfileInformationPageState extends State<ProfileInformationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _documentId = '';
  bool _isLoading = false;
  File? _selectedImage; // Variable to hold selected image
  String? _imgUrl; // Variable to hold the image URL
  String _membershipStatus = 'Not Registered'; // Default membership status

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          var userData = userDoc.data() as Map<String, dynamic>?;

          if (userData != null) {
            String fullName = userData['name'] ?? '';

            // Split the full name into first name and last name
            List<String> nameParts = fullName.split(' ');
            _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
            _lastNameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

            setState(() {
              _documentId = userDoc.id;
              _emailController.text = userData['email'] ?? currentUser.email ?? '';
              _phoneController.text = userData['phone'] ?? '';
              _nicController.text = userData['nic'] ?? '';
              _addressController.text = userData['address'] ?? '';
              _imgUrl = userData['img']; // Load the existing image URL
              _membershipStatus = userData['membership'] ?? 'Not Registered'; // Load membership status with default
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User data not found')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is currently logged in')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Upload the image and update the user data once it's uploaded
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      String fileName = 'profile_${_auth.currentUser!.uid}.jpg';
      Reference storageRef = _storage.ref().child('profile_pictures').child(fileName);

      UploadTask uploadTask = storageRef.putFile(_selectedImage!);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _imgUrl = downloadUrl; // Set the image URL
      });

      // Update user data with the new image URL after uploading
      await _updateUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture uploaded and profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateUserData() async {
    if (_documentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user document ID found.')),
      );
      return;
    }

    try {
      // Ensure membership status is not empty or null
      if (_membershipStatus.isEmpty) {
        _membershipStatus = 'Not Registered';
      }

      // Updated data map including the membership status
      Map<String, dynamic> updatedData = {
        'name': '${_firstNameController.text} ${_lastNameController.text}',
        'email': _emailController.text,
        'phone': _phoneController.text,
        'nic': _nicController.text,
        'address': _addressController.text,
        'membership': _membershipStatus, // Include the membership status
        'img': _imgUrl // Ensure img is only included if not null
      };

      // Remove null entries to avoid any null value errors
      updatedData.removeWhere((key, value) => value == null);

      await _firestore.collection('users').doc(_documentId).update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    }
  }

  // Method to navigate to Fresco Registration
  void _navigateToFrescoRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FrescoRegistration()), // Navigate to FrescoRegistration.dart
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Information',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3A6810),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateUserData,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4EDD2B)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage, // Trigger image picker on tap
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _imgUrl != null
                              ? NetworkImage(_imgUrl!)
                              : const AssetImage('assets/clipboard.png') as ImageProvider, // Display profile picture
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildProfileItem('First Name', _firstNameController),
                    const SizedBox(height: 20),
                    _buildProfileItem('Last Name', _lastNameController),
                    const SizedBox(height: 20),
                    _buildProfileItem('Email', _emailController),
                    const SizedBox(height: 20),
                    _buildProfileItem('Phone No', _phoneController),
                    const SizedBox(height: 20),
                    _buildProfileItem('NIC No', _nicController),
                    const SizedBox(height: 20),
                    _buildProfileItem('Address', _addressController),
                    const SizedBox(height: 20),
                    _buildMembershipItem(), // Add the membership item
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  // Method to build the membership item
  Widget _buildMembershipItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Membership',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: _navigateToFrescoRegistration, // Navigate on clicking "Not Registered"
              child: Text(
                _membershipStatus,
                style: TextStyle(
                  fontSize: 16,
                  color: _membershipStatus == 'Not Registered' ? Colors.red : Colors.green, // Color based on status
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: Color(0xFF4CAF50)),
              onPressed: _navigateToFrescoRegistration, // Navigate to Fresco_Registration.dart when pressed
            ),
          ],
        ),
      ],
    );
  }

  // Reusable method to build profile items
  Widget _buildProfileItem(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
