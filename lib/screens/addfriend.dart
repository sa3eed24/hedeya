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
  bool _isChecking = false;
  String? _errorMessage;
  bool _isExistingUser = false; // Track if the email belongs to an existing user

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
      _isChecking = false;
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
      // Try to access the friends collection - this will be more likely to succeed
      // since the current user should have permission to read their own friends
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return false;
      }

      await FirebaseFirestore.instance
          .collection('friends')
          .where('createdBy', isEqualTo: currentUser.uid)
          .limit(1)
          .get();
      return true;
    } catch (e) {
      debugPrint('Firestore connection test failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> _checkIfFriendExists() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        _showError('You must be logged in to add a friend');
        return false;
      }

      final String userId = currentUser.uid;

      // Query Firestore to check if a friend with the same name and email exists
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('friends')
          .where('name', isEqualTo: name)
          .where('email', isEqualTo: email)
          .where('createdBy', isEqualTo: userId)
          .get();

      if (result.docs.isNotEmpty) {
        _showError('A friend with this name and email already exists in your list.');
        return true; // Friend exists
      }

      return false; // Friend doesn't exist
    } catch (e) {
      debugPrint('Error checking if friend exists: ${e.toString()}');
      _showError('Error checking database: ${e.toString()}');
      return false; // Assume friend doesn't exist due to error
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  // Modified to use Firebase Auth methods instead of direct Firestore query
  Future<bool> _checkIfUserExists() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
      _isExistingUser = false;
    });

    try {
      final String email = _emailController.text.trim();

      if (email.isEmpty || !email.contains('@')) {
        _showError('Please enter a valid email address');
        return false;
      }

      // Query Firestore to check if a user with this email exists
      final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get(GetOptions(source: Source.server));

      if (userSnapshot.docs.isNotEmpty) {
        debugPrint('User found in Firestore: $email');
        setState(() => _isExistingUser = true);
        return true;
      } else {
        debugPrint('No user found with email: $email');
        _showError('No user account found with this email.');
        return false;
      }
    } catch (e) {
      debugPrint('Error checking if user exists: ${e.toString()}');
      _showError('Error: ${e.toString()}');
      return false;
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  // Modified function to add friend only if user exists
  Future<void> _addFriend() async {
    // Validate form inputs
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    // Check if Firestore connection works
    final firestoreConnected = await _checkFirestoreConnection();
    if (!firestoreConnected) {
      _showError('Could not connect to database. Check your internet connection.');
      return;
    }

    // Check if friend already exists
    final friendExists = await _checkIfFriendExists();
    if (friendExists) return;

    // Check if user exists in Firestore
    if (!_isExistingUser) {
      final userExists = await _checkIfUserExists();
      if (!userExists) {
        setState(() => _isUploading = false);
        return; // Don't proceed if user doesn't exist
      }
    }

    try {
      // Add friend logic remains the same
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showError('You must be logged in to add a friend');
        return;
      }

      final String userId = currentUser.uid;

      final friendDocRef = await FirebaseFirestore.instance.collection('friends').add({
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'upcomingEvents': 0,
        'createdBy': userId,
        'friendUserId': '', // Leave blank for now
        'isRegisteredUser': true, // Set to true
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      debugPrint('Friend added with ID: ${friendDocRef.id}');
      _showSuccess('Friend added successfully!');
      Navigator.pop(context); // Return to previous screen
    } catch (e) {
      debugPrint('Error adding friend: ${e.toString()}');
      _showError('Error adding friend: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFB6C1), Color(0xFFFF4757)], // Light pink to darker red gradient
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Add Friend',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
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

                  if (_isExistingUser)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'User found with this email! You can add them as your friend.',
                              style: TextStyle(color: Colors.green[900]),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Friend Name',
                              hintText: 'Enter your friend\'s name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.person),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            textCapitalization: TextCapitalization.words,
                            enabled: !_isUploading && !_isChecking,
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
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              hintText: 'Enter your friend\'s phone number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.phone),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            keyboardType: TextInputType.phone,
                            enabled: !_isUploading && !_isChecking,
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
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'Enter your friend\'s email address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.email),
                              suffixIcon: _emailController.text.isNotEmpty
                                  ? IconButton(
                                icon: Icon(
                                  Icons.search,
                                  color: _isChecking ? Colors.grey : Colors.blue,
                                ),
                                onPressed: _isChecking ? null : () {
                                  if (_emailController.text.isNotEmpty && _emailController.text.contains('@')) {
                                    _checkIfUserExists();
                                  }
                                },
                              )
                                  : null,
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_isUploading && !_isChecking,
                            onChanged: (_) {
                              // Reset the existing user flag when email changes
                              if (_isExistingUser) {
                                setState(() => _isExistingUser = false);
                              }
                            },
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

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '* You can only add users who are registered in the app',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.search),
                                label: const Text('Check if user exists'),
                                onPressed: (_isUploading || _isChecking)
                                    ? null
                                    : () {
                                  if (_emailController.text.isNotEmpty &&
                                      _emailController.text.contains('@')) {
                                    _checkIfUserExists();
                                  } else {
                                    _showError('Please enter a valid email first');
                                  }
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          ElevatedButton.icon(
                            onPressed: (_isUploading || _isChecking || !_isExistingUser)
                                ? null
                                : _addFriend,
                            icon: (_isUploading || _isChecking)
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
                              _isChecking
                                  ? 'Checking...'
                                  : (_isUploading
                                  ? 'Adding Friend...'
                                  : (_isExistingUser
                                  ? 'Add Friend'
                                  : 'Verify User First')),
                              style: const TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: _isExistingUser ? Colors.pink : Colors.grey,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          if (_isUploading || _isChecking)
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Column(
                                children: [
                                  const LinearProgressIndicator(),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isChecking
                                        ? 'Checking database... Please wait'
                                        : 'Adding friend... Please wait',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}