import 'package:flutter/material.dart';
import '../model/gift_model.dart';

class GiftCard extends StatefulWidget {
  final gift_model gift;
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
    final newStatus = value ?? false;
    setState(() {
      _status = newStatus;
    });
    widget.onStatusChanged(_status);



  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gift image in a constrained box
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: Image.network(
                  widget.gift.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Gift details
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
                    '${widget.gift.price.toStringAsFixed(2)}',
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
            // Checkbox for status
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