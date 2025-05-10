import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/gift_model.dart';

class GiftCard extends StatefulWidget {
  final GiftModel gift;
  final ValueChanged<bool> onStatusChanged;

  const GiftCard({
    Key? key,
    required this.gift,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  _GiftCardState createState() => _GiftCardState();
}

class _GiftCardState extends State<GiftCard> {
  late bool _status;

  @override
  void initState() {
    super.initState();
    _status = widget.gift.status;
  }

  void _toggleStatus(bool? value) {
    if (value == null) return;

    setState(() {
      _status = value;
    });
    widget.onStatusChanged(_status);
  }

  Widget _buildGiftImage() {
    if (widget.gift.image != null && widget.gift.image!.isNotEmpty) {
      // Check if the image is base64 encoded
      if (widget.gift.image!.startsWith('data:image')) {
        // Already properly formatted data URI
        return Image.memory(
          base64Decode(widget.gift.image!.split(',')[1]),
          width: 100, // Increased image width
          height: 100, // Increased image height
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
        );
      } else {
        // Assume it's raw base64 data without data URI prefix
        // Add data URI prefix if it's missing
        final dataUri = 'data:image/png;base64,${widget.gift.image!}';
        return Image.memory(
          base64Decode(dataUri.split(',')[1]),
          width: 100, // Increased image width
          height: 100, // Increased image height
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
        );
      }
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 100, // Increased placeholder width
      height: 100, // Increased placeholder height
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0), // Increased border radius
      ),
      child: Icon(Icons.card_giftcard, size: 40, color: Colors.grey[600]), // Increased icon size
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0), // Increased margins
      elevation: 4.0, // Increased elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Increased border radius
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Increased padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0), // Increased border radius
              child: _buildGiftImage(),
            ),
            const SizedBox(width: 20), // Increased spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.gift.name,
                    style: const TextStyle(
                      fontSize: 20, // Increased font size
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8), // Increased spacing
                  Text(
                    widget.gift.description,
                    style: TextStyle(
                      fontSize: 14, // Increased font size
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8), // Increased spacing
                  Text(
                    '\$${widget.gift.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16, // Increased font size
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_status && widget.gift.pledgedUser.isNotEmpty) ...[
                    const SizedBox(height: 8), // Increased spacing
                    Row(
                      children: [
                        Icon(Icons.person, size: 18, color: Colors.blue[700]), // Increased icon size
                        const SizedBox(width: 8), // Increased spacing
                        Expanded(
                          child: Text(
                            'Pledged by: ${widget.gift.pledgedUser}',
                            style: TextStyle(
                              fontSize: 14, // Increased font size
                              color: Colors.blue[700],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Checkbox(
              value: _status,
              onChanged: _toggleStatus,
              activeColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}