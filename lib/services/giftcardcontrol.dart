import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/gift_model.dart';

class GiftCardControl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user ID or throw an error if not authenticated
  String _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  // Get all gifts for an event
  Future<List<GiftModel>> getEventGifts(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('gifts')
          .where('eventId', isEqualTo: eventId)
          .get();

      return snapshot.docs
          .map((doc) => GiftModel.fromJson(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      print('Error getting event gifts: $e');
      throw e;
    }
  }

  // Add a new gift with current user as owner
  Future<void> addGift(GiftModel gift) async {
    try {
      // Make sure we set the current user's ID as the owner
      final userId = _getCurrentUserId();
      final giftWithUser = gift.copyWith(userId: userId);

      await _firestore.collection('gifts').add(giftWithUser.toJson());
    } catch (e) {
      print('Error adding gift: $e');
      throw e;
    }
  }

  // Update gift status (pledge/unpledge)
  Future<void> updateGiftStatus({
    required String giftId,
    required bool status,
    String? pledgedUser,
  }) async {
    try {
      // First check if the gift exists and can be modified
      final doc = await _firestore.collection('gifts').doc(giftId).get();
      if (!doc.exists) {
        throw Exception('Gift not found');
      }

      // Get the gift data
      final giftData = doc.data() as Map<String, dynamic>;
      final currentUserId = _getCurrentUserId();

      // Check if this is the user's own gift list
      final bool isOwner = giftData['userId'] == currentUserId;

      // If pledging/unpledging someone else's gift, just update status
      // If modifying your own gift, check if it's already pledged
      if (isOwner && giftData['status'] == true && status == false) {
        // Owner can unpledge their own gift
        await _firestore.collection('gifts').doc(giftId).update({
          'status': status,
          'pledgedUser': pledgedUser,
        });
      } else if (!isOwner) {
        // Non-owner can pledge/unpledge gifts
        await _firestore.collection('gifts').doc(giftId).update({
          'status': status,
          'pledgedUser': status ? currentUserId : '',
        });
      } else if (isOwner && giftData['status'] == false) {
        // Owner can update unpledged gifts
        await _firestore.collection('gifts').doc(giftId).update({
          'status': status,
          'pledgedUser': pledgedUser,
        });
      } else {
        throw Exception('Cannot modify pledged gift');
      }
    } catch (e) {
      print('Error updating gift status: $e');
      throw e;
    }
  }

  // Delete a gift - only the owner can delete their gift
  Future<void> deleteGift(String giftId) async {
    try {
      // First check if the gift exists and belongs to the current user
      final doc = await _firestore.collection('gifts').doc(giftId).get();
      if (!doc.exists) {
        throw Exception('Gift not found');
      }

      final giftData = doc.data() as Map<String, dynamic>;

      // Check if the gift is already pledged
      if (giftData['status'] == true) {
        throw Exception('Cannot delete a pledged gift');
      }

      // If all checks pass, delete the gift
      await _firestore.collection('gifts').doc(giftId).delete();
    } catch (e) {
      print('Error deleting gift: $e');
      throw e;
    }
  }

  // Update gift details (name, description, price, image)
  Future<void> updateGiftDetails(GiftModel updatedGift) async {
    try {
      if (updatedGift.id == null) {
        throw Exception('Gift ID is required for updates');
      }

      // Check if the gift exists and belongs to the current user
      final doc = await _firestore.collection('gifts').doc(updatedGift.id).get();
      if (!doc.exists) {
        throw Exception('Gift not found');
      }

      final giftData = doc.data() as Map<String, dynamic>;
      final currentUserId = _getCurrentUserId();

      // Verify ownership - only the owner can update their gift
      if (giftData['userId'] != currentUserId) {
        throw Exception('You can only update gifts you created');
      }

      // Check if the gift is already pledged - can't modify pledged gifts
      if (giftData['status'] == true) {
        throw Exception('Cannot modify a pledged gift');
      }

      // If all checks pass, update the gift
      await _firestore.collection('gifts').doc(updatedGift.id).update({
        'name': updatedGift.name,
        'description': updatedGift.description,
        'price': updatedGift.price,
        'imageUrl': updatedGift.image,
      });
    } catch (e) {
      print('Error updating gift details: $e');
      throw e;
    }
  }
}