import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/gift_model.dart';
import '../model/event_model.dart';

class GiftCardControl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference get eventsRef => _firestore.collection('events');
  CollectionReference get giftsRef => _firestore.collection('gifts');

  Future<List<GiftModel>> getEventGifts(String eventId) async {
    try {
      final QuerySnapshot snapshot = await giftsRef
          .where('eventId', isEqualTo: eventId)
          .get();

      return snapshot.docs.map((doc) {
        return GiftModel.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching event gifts: $e');
      return [];
    }
  }

  Future<EventModel?> getEvent(String eventId) async {
    try {
      final DocumentSnapshot snapshot = await eventsRef.doc(eventId).get();

      if (snapshot.exists) {
        return EventModel.fromJson(snapshot.data() as Map<String, dynamic>, id: snapshot.id);
      }
      return null;
    } catch (e) {
      print('Error fetching event: $e');
      return null;
    }
  }

  Future<bool> addGift(GiftModel gift) async {
    try {
      // Validate required fields
      if (gift.name.isEmpty || gift.eventId.isEmpty) {
        print('Gift validation failed: name or eventId is empty');
        return false;
      }

      // Add document with debug logging
      print('Attempting to add gift: ${gift.toJson()}');
      final docRef = await giftsRef.add(gift.toJson());
      print('Gift added successfully with ID: ${docRef.id}');
      return true;
    } catch (e, stackTrace) {
      print('Error adding gift: $e');
      print('Stack trace: $stackTrace');

      // Check for specific Firebase errors
      if (e is FirebaseException) {
        print('Firebase error code: ${e.code}');
        print('Firebase error message: ${e.message}');
      }

      return false;
    }
  }

  Future<bool> updateGiftStatus(String giftId, bool status, String pledgedUser) async {
    try {
      await giftsRef.doc(giftId).update({
        'status': status,
        'pledgedUser': pledgedUser,
      });
      return true;
    } catch (e) {
      print('Error updating gift status: $e');
      return false;
    }
  }

  Future<bool> deleteGift(String giftId) async {
    try {
      await giftsRef.doc(giftId).delete();
      return true;
    } catch (e) {
      print('Error deleting gift: $e');
      return false;
    }
  }

  Future<List<EventModel>> getUserEvents() async {
    try {
      if (currentUserId == null) return [];

      final QuerySnapshot snapshot = await eventsRef
          .where('owner', isEqualTo: currentUserId)
          .get();

      return snapshot.docs.map((doc) {
        return EventModel.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching user events: $e');
      return [];
    }
  }

}