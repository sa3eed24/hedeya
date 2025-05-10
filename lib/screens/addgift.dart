import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../model/gift_model.dart';

class AddGift extends StatefulWidget {
  final String eventId;

  const AddGift({Key? key, required this.eventId}) : super(key: key);

  @override
  State<AddGift> createState() => _AddGiftState();
}

class _AddGiftState extends State<AddGift> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _selectedImage;
  String? _base64Image; // Store the base64 string
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final base64String = await _convertImageToBase64(imageFile);

        setState(() {
          _selectedImage = imageFile;
          _base64Image = base64String;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting image: ${e.toString()}');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final base64String = await _convertImageToBase64(imageFile);

        setState(() {
          _selectedImage = imageFile;
          _base64Image = base64String;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error taking photo: ${e.toString()}');
    }
  }

  Future<String> _convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      // Return as data URI and remove whitespace
      return 'data:image/png;base64,${base64String.replaceAll(RegExp(r'\s'), '')}';
    } catch (e) {
      _showErrorSnackBar('Error converting image to base64: ${e.toString()}');
      rethrow;
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _base64Image = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      try {
        double price;
        try {
          price = double.parse(_priceController.text);
        } catch (e) {
          _showErrorSnackBar('Invalid price format');
          return;
        }

        // Assuming user authentication and other logic are handled elsewhere
        final newGift = GiftModel(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          image: _base64Image, // Using the base64 string
          status: false,
          pledgedUser: '',
          eventId: widget.eventId,
          userId: 'some_user_id', // Replace with actual user ID
        );

        Navigator.pop(context, newGift);
      } catch (e) {
        _showErrorSnackBar('Error creating gift: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.redAccent],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Center(
                          child: Text(
                            'Add New Gift',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: _selectedImage != null
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      base64Decode(_base64Image!.split(',')[1]),
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                      : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                      SizedBox(height: 10),
                                      Text('Tap buttons below to add photo',
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                if (_selectedImage != null)
                                  IconButton(
                                    icon: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white),
                                    ),
                                    onPressed: _removeImage,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Gallery'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed: _takePhoto,
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Camera'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Gift Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a gift name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                labelText: 'Price',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                prefixText: '\$',
                              ),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a price';
                                }
                                try {
                                  final price = double.parse(value);
                                  if (price < 0) {
                                    return 'Price cannot be negative';
                                  }
                                } catch (e) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Add Gift',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}