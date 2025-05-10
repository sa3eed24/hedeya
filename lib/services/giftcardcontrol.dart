import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../model/event_model.dart';
import '../model/gift_model.dart';

class GiftCardControl {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GiftCardControl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference get eventsRef => _firestore.collection('events');
  CollectionReference get giftsRef => _firestore.collection('gifts');

  Future<List<GiftModel>> getEventGifts(String eventId) async {
    try {
      if (eventId.isEmpty) throw ArgumentError('eventId cannot be empty');

      debugPrint('[DEBUG] Fetching gifts for event: $eventId');
      final QuerySnapshot snapshot = await giftsRef
          .where('eventId', isEqualTo: eventId)
          .limit(100)
          .get();

      debugPrint('[DEBUG] Found ${snapshot.docs.length} gifts');

      return snapshot.docs.map((doc) {
        return GiftModel.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching event gifts: $e');
      rethrow;
    }
  }

  Future<String> addGift(GiftModel gift) async {
    try {
      if (gift.name.isEmpty || gift.eventId.isEmpty) {
        throw ArgumentError('Gift name and eventId cannot be empty');
      }

      final DocumentReference docRef = giftsRef.doc();
      final String giftId = docRef.id;

      final giftData = gift.copyWith(id: giftId).toJson();

      await docRef.set(giftData);

      debugPrint('[DEBUG] Gift saved successfully with Firestore ID: $giftId');
      return giftId;
    } catch (e, stackTrace) {
      debugPrint('Error adding gift: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateGiftStatus({
    required String giftId,
    required bool status,
    String? pledgedUser,
  }) async {
    try {
      if (giftId.isEmpty) throw ArgumentError('giftId cannot be empty');

      debugPrint('[DEBUG] Updating gift status: $giftId to $status');

      final updateData = <String, dynamic>{
        'status': status,
        if (pledgedUser != null) 'pledgedUser': pledgedUser,
      };

      await giftsRef.doc(giftId).update(updateData);
      debugPrint('[DEBUG] Gift status updated successfully');
    } catch (e) {
      debugPrint('Error updating gift status: $e');
      rethrow;
    }
  }

  Future<void> deleteGift(String giftId) async {
    try {
      if (giftId.isEmpty) throw ArgumentError('giftId cannot be empty');

      debugPrint('[DEBUG] Deleting gift with Firestore ID: $giftId');
      await giftsRef.doc(giftId).delete();
      debugPrint('[DEBUG] Gift deleted successfully with ID: $giftId');
    } catch (e) {
      debugPrint('Error deleting gift with ID $giftId: $e');
      rethrow;
    }
  }

  String generateUniqueId() {
    return Uuid().v4();
  }

  Future<List<EventModel>> getUserEvents() async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final QuerySnapshot snapshot = await eventsRef
          .where('owner', isEqualTo: userId)
          .limit(100)
          .get();

      return snapshot.docs.map((doc) {
        return EventModel.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching user events: $e');
      rethrow;
    }
  }
}