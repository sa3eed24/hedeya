import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    debugPrint('ERROR: $message');
    setState(() {
      _errorMessage = message;
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _checkFirestoreConnection() async {
    try {
      // Try to access the friends collection
      await FirebaseFirestore.instance.collection('friends').limit(1).get();
      return true;
    } catch (e) {
      debugPrint('Firestore connection test failed: ${e.toString()}');
      return false;
    }
  }

  Future<void> _addFriend() async {
    // Validate form inputs
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    // First check if we can connect to Firestore
    final firestoreConnected = await _checkFirestoreConnection();
    if (!firestoreConnected) {
      _showError('Could not connect to database. Please check your internet connection.');
      return;
    }

    try {
      // Get current user ID for reference
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showError('You must be logged in to add a friend');
        return;
      }

      final String userId = currentUser.uid;
      debugPrint('Current user ID: $userId');
      debugPrint('Adding friend with name: ${_nameController.text.trim()}');

      // Add friend to Firestore
      final friendDocRef = await FirebaseFirestore.instance.collection('friends').add({
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'upcomingEvents': 0,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      debugPrint('Friend document added with ID: ${friendDocRef.id}');

      if (mounted) {
        _showSuccess('Friend added successfully!');
        Navigator.pop(context); // Return to previous screen
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      _showError('Authentication error: ${e.message}');
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException: ${e.code} - ${e.message}');

      if (e.code == 'permission-denied') {
        _showError('Permission denied. Check your database rules.');
      } else if (e.code == 'unavailable') {
        _showError('Firebase service unavailable. Check your internet connection.');
      } else {
        _showError('Firebase error: ${e.message}');
      }
    } catch (e) {
      debugPrint('General error: ${e.toString()}');
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[900]),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Friend Name',
                    hintText: 'Enter your friend\'s name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: !_isUploading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your friend\'s phone number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  enabled: !_isUploading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a phone number';
                    }
                    // Basic phone number validation
                    if (value.trim().length < 7) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your friend\'s email address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isUploading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an email address';
                    }
                    // Basic email validation
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _addFriend,
                  icon: _isUploading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.person_add),
                  label: Text(
                    _isUploading ? 'Adding Friend...' : 'Add Friend',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                if (_isUploading)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      children: [
                        const LinearProgressIndicator(),
                        const SizedBox(height: 8),
                        Text(
                          'Adding friend... Please wait',
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}