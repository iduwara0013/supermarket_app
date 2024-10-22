import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/services.dart'; // Needed for input formatters
import 'Fresco_Registration.dart';

class ProfileInformationPage extends StatefulWidget {
  const ProfileInformationPage({super.key});

  @override
  _ProfileInformationPageState createState() => _ProfileInformationPageState();
}

class _ProfileInformationPageState extends State<ProfileInformationPage> {
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
  File? _selectedImage;
  String? _imgUrl;
  String _membershipStatus = 'Not Registered';

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
      QuerySnapshot currentUserSnapshot = await _firestore
          .collection('current_user')
          .get();

      if (currentUserSnapshot.docs.isNotEmpty) {
        DocumentSnapshot currentUserDoc = currentUserSnapshot.docs.first;
        var currentUserData = currentUserDoc.data() as Map<String, dynamic>?;
        String? userId = currentUserData?['userId'];

        if (userId != null) {
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(userId)
              .get();

          if (userDoc.exists) {
            var userData = userDoc.data() as Map<String, dynamic>?;

            if (userData != null) {
              String fullName = userData['name'] ?? '';
              List<String> nameParts = fullName.split(' ');

              String firstName = nameParts.isNotEmpty ? nameParts.first : '';
              String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

              _firstNameController.text = firstName;
              _lastNameController.text = lastName;
              _emailController.text = userData['email'] ?? '';
              _phoneController.text = userData['phone'] ?? '';
              _nicController.text = userData['nic'] ?? '';
              _addressController.text = userData['address'] ?? '';
              _imgUrl = userData['img'];
              _membershipStatus = userData['membership'] ?? 'Not Registered';
              _documentId = userDoc.id;
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User data not found in users collection')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current user data not found')),
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
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      String fileName = 'profile_${_documentId}.jpg';
      Reference storageRef = _storage.ref().child('profile_pictures').child(fileName);

      UploadTask uploadTask = storageRef.putFile(_selectedImage!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _imgUrl = downloadUrl;
      });
      await _updateUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture uploaded successfully')),
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
      Map<String, dynamic> updatedData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'nic': _nicController.text,
        'address': _addressController.text,
        'membership': _membershipStatus,
        'img': _imgUrl,
      };

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

  void _navigateToFrescoRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FrescoRegistration()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Information'),
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
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _imgUrl != null
                              ? NetworkImage(_imgUrl!)
                              : const AssetImage('assets/clipboard.png') as ImageProvider,
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
                    _buildProfileItem('Phone No', _phoneController, isPhone: true),
                    const SizedBox(height: 20),
                    _buildNicField(),
                    const SizedBox(height: 20),
                    _buildProfileItem('Address', _addressController),
                    const SizedBox(height: 20),
                    _buildMembershipItem(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileItem(String label, TextEditingController controller, {bool isPhone = false}) {
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
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          inputFormatters: isPhone
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ]
              : [],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildNicField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NIC No',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nicController,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9Vv]')),
            LengthLimitingTextInputFormatter(12),
          ],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'New NIC: 12 digits, Old NIC: 8 digits followed by "V"',
          ),
        ),
      ],
    );
  }

  Widget _buildMembershipItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Membership Status',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            if (_membershipStatus == 'Not Registered') {
              _navigateToFrescoRegistration();
            }
          },
          child: Row(
            children: [
              Text(
                _membershipStatus,
                style: TextStyle(
                  color: _membershipStatus == 'Not Registered' ? Colors.red : Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_membershipStatus == 'Not Registered') ...[
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward, color: Colors.red),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
