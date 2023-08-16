import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _favoriteFoodsController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  String _profilePictureUrl = ''; // To store the profile picture URL

  Future<void> _uploadImageToStorage() async {
    // Implement image upload logic to Firebase Storage
    // Update _profilePictureUrl with the uploaded image URL
  }

Future<void> _saveProfileToFirestore() async {
  try {
    // Get the currently authenticated user
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      String? userEmail = user.email;
      await FirebaseFirestore.instance.collection('users').doc(userEmail).set({
        'full_name': _fullNameController.text,
        'email': userEmail,
        'phone_number': _phoneNumberController.text,
        'favorite_foods': _favoriteFoodsController.text,
        'location': _locationController.text,
        'gender': _genderController.text,
        'age': _ageController.text,
        'profile_picture_url': _profilePictureUrl,
      });
      // Show success message to the user
    } else {
      // Handle case when the user is not authenticated
    }
  } catch (e) {
    // Show error message to the user
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
           GestureDetector(
  onTap: _uploadImageToStorage,
  child: CircleAvatar(
    radius: 50,
    backgroundImage: _profilePictureUrl.isEmpty
        ? null // No background image for the icon
        : NetworkImage(_profilePictureUrl), // Display image from URL
    child: _profilePictureUrl.isEmpty
        ? Icon(Icons.person) // Icon when no profile picture
        : null,
  ),
),

            const SizedBox(height: 16.0),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _favoriteFoodsController,
              decoration: const InputDecoration(labelText: 'Favorite Foods'),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: _genderController,
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveProfileToFirestore,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
