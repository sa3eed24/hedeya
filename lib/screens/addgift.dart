import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/gift_model.dart';

class AddGift extends StatefulWidget {
  const AddGift({super.key});

  @override
  State<AddGift> createState() => _AddGiftState();
}

class _AddGiftState extends State<AddGift> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _selectedImage;
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
        setState(() {
          _selectedImage = File(pickedFile.path);
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
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error taking photo: ${e.toString()}');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _scanBarcode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Configure barcode scanner options
      final ScanOptions options = ScanOptions(
        strings: {
          'cancel': 'Cancel',
          'flash_on': 'Flash on',
          'flash_off': 'Flash off',
        },
        restrictFormat: [BarcodeFormat.qr, BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upce, BarcodeFormat.upce],
        useCamera: -1, // -1 means auto-select
        android: const AndroidOptions(
          aspectTolerance: 0.5,
          useAutoFocus: true,
        ),
      );

      // Start the barcode scanner
      final ScanResult result = await BarcodeScanner.scan(options: options);

      // Process result only if it's successful
      if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
        // Fetch product details from barcode
        await _fetchProductDetails(result.rawContent);
        _showSuccessSnackBar('Barcode scanned: ${result.rawContent}');
      } else if (result.type == ResultType.Cancelled) {
        _showErrorSnackBar('Scan cancelled');
      } else {
        _showErrorSnackBar('Scan failed or empty result');
      }
    } catch (e) {
      _showErrorSnackBar('Error scanning barcode: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProductDetails(String barcode) async {
    try {
      // Display loading state
      setState(() {
        _isLoading = true;
      });

      // Call the barcode lookup API - using Open Food Facts as an example
      // You may want to use a different API based on your needs
      final response = await http.get(
        Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if product was found
        if (data['status'] == 1) {
          final product = data['product'];

          // Populate form fields with product details
          setState(() {
            // Set product name
            _nameController.text = product['product_name'] ??
                product['generic_name'] ??
                'Product #${barcode.substring(barcode.length > 4 ? barcode.length - 4 : 0)}';

            // Set product description - combine various available fields
            List<String> descriptionParts = [];
            if (product['brands'] != null) descriptionParts.add('Brand: ${product['brands']}');
            if (product['quantity'] != null) descriptionParts.add('Quantity: ${product['quantity']}');
            if (product['categories'] != null) descriptionParts.add('Category: ${product['categories']}');

            // Add ingredients if available
            if (product['ingredients_text'] != null && product['ingredients_text'].toString().isNotEmpty) {
              descriptionParts.add('Ingredients: ${product['ingredients_text']}');
            }

            // Fallback if no description details are available
            if (descriptionParts.isEmpty) {
              descriptionParts.add('Item with barcode: $barcode');
            }

            _descriptionController.text = descriptionParts.join('\n');

            // Try to set price if available (rarely provided by food databases)
            // This would typically come from your own database or a retail API
            _priceController.text = '';

            // Download and set product image if available
            _downloadProductImage(product);
          });
        } else {
          // Product not found, set default values
          _setDefaultProductValues(barcode);
          _showErrorSnackBar('Product details not found for this barcode');
        }
      } else {
        // API error, set default values
        _setDefaultProductValues(barcode);
        _showErrorSnackBar('Failed to fetch product details');
      }
    } catch (e) {
      // Error in API call, set default values
      _setDefaultProductValues(barcode);
      _showErrorSnackBar('Error fetching product details: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadProductImage(dynamic product) async {
    try {
      // Check for image URLs in different fields
      String? imageUrl = product['image_url'] ??
          product['image_front_url'] ??
          product['image_front_small_url'];

      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Download the image
        final response = await http.get(Uri.parse(imageUrl));

        if (response.statusCode == 200) {
          // Create a temporary file to store the image
          final tempDir = await Directory.systemTemp.createTemp('gift_images');
          final tempFile = File('${tempDir.path}/product_image.jpg');

          // Write the image data to the file
          await tempFile.writeAsBytes(response.bodyBytes);

          // Set the image file
          setState(() {
            _selectedImage = tempFile;
          });
        }
      }
    } catch (e) {
      // Silently handle image download errors
      print('Error downloading product image: ${e.toString()}');
      // Don't show an error to the user as this is not critical
    }
  }

  void _setDefaultProductValues(String barcode) {
    setState(() {
      _nameController.text = 'Product #${barcode.substring(barcode.length > 4 ? barcode.length - 4 : 0)}';
      _descriptionController.text = 'Item with barcode: $barcode';
      _priceController.text = '';
      // Don't change the image
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
        // Parse the price with proper error handling
        double price;
        try {
          price = double.parse(_priceController.text);
        } catch (e) {
          _showErrorSnackBar('Invalid price format');
          return;
        }

        final newGift = gift_model(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          imageFile: _selectedImage,
          status: false,
          pleged_user: '',  // Using the original property name from your model
          eventid: 0,  // Default to 0, you may want to pass this as a parameter
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
                                    child: Image.file(
                                      _selectedImage!,
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
                            // Image selection buttons
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
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
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
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                                  ),
                                  onPressed: _scanBarcode,
                                  tooltip: 'Scan Barcode',
                                ),
                              ],
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 16),
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
              // Loading overlay
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