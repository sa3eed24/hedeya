import 'package:flutter/material.dart';
import '../model/gift_model.dart';
import 'dart:io';

class GiftCard extends StatefulWidget {
  final gift_model gift;
  final ValueChanged<bool> onStatusChanged;
  final VoidCallback? onDelete;

  const GiftCard({
    Key? key,
    required this.gift,
    required this.onStatusChanged,
    this.onDelete,
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
    final newStatus = value ?? false;
    setState(() {
      _status = newStatus;
    });
    widget.onStatusChanged(_status);
  }

  Widget _buildGiftImage() {
    if (widget.gift.imageFile != null) {
      return Image.file(
        widget.gift.imageFile!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        color: Colors.grey[200],
        child: Icon(Icons.card_giftcard, color: Colors.grey[600]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.gift.name + widget.gift.hashCode.toString()),
      direction: widget.gift.status ? DismissDirection.none : DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (widget.gift.status) return false;
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Gift'),
            content: Text('Are you sure you want to delete ${widget.gift.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        if (widget.onDelete != null) {
          widget.onDelete!();
        }
      },
      background: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: _buildGiftImage(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.gift.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.gift.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${widget.gift.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_status && widget.gift.pleged_user.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.blue[700]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Pledged by: ${widget.gift.pleged_user}',
                              style: TextStyle(
                                fontSize: 12,
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
      ),
    );
  }
}