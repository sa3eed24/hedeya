import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../model/event_model.dart';
import '../model/gift_model.dart';

class GiftCardControl {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Dependency injection for easier testing
  GiftCardControl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference get eventsRef => _firestore.collection('events');
  CollectionReference get giftsRef => _firestore.collection('gifts');

  // Fetch gifts for a specific event
  Future<List<GiftModel>> getEventGifts(String eventId) async {
    try {
      if (eventId.isEmpty) throw ArgumentError('eventId cannot be empty');

      final QuerySnapshot snapshot = await giftsRef
          .where('eventId', isEqualTo: eventId)
          .limit(100) // Add limit to prevent loading too much data
          .get();

      return snapshot.docs.map((doc) {
        return GiftModel.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching event gifts: $e');
      rethrow; // Or return a Failure object
    }
  }

  // Fetch a specific event by ID
  Future<EventModel?> getEvent(String eventId) async {
    try {
      if (eventId.isEmpty) throw ArgumentError('eventId cannot be empty');

      final DocumentSnapshot snapshot = await eventsRef.doc(eventId).get();
      return snapshot.exists
          ? EventModel.fromJson(snapshot.data() as Map<String, dynamic>, id: snapshot.id)
          : null;
    } catch (e) {
      print('Error fetching event: $e');
      rethrow;
    }
  }

  // Add a new gift to the database
  Future<void> addGift(GiftModel gift) async {
    try {
      // Validate required fields
      if (gift.name.isEmpty || gift.eventId.isEmpty) {
        throw ArgumentError('Gift name and eventId cannot be empty');
      }

      // Generate a unique ID if not provided
      if (gift.id == null || gift.id!.isEmpty) {
        gift.id = generateUniqueId();
      }

      // Use the gift.id as the Firestore document ID
      await giftsRef.doc(gift.id).set(gift.toJson());
      print('Gift added successfully with ID: ${gift.id}');
    } catch (e, stackTrace) {
      print('Error adding gift: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Update the status of a gift
  Future<void> updateGiftStatus({
    required String giftId,
    required bool status,
    String? pledgedUser,
  }) async {
    try {
      if (giftId.isEmpty) throw ArgumentError('giftId cannot be empty');

      final updateData = <String, dynamic>{
        'status': status,
        if (pledgedUser != null) 'pledgedUser': pledgedUser,
      };

      await giftsRef.doc(giftId).update(updateData);
    } catch (e) {
      print('Error updating gift status: $e');
      rethrow;
    }
  }

  // Delete a gift from the database
  Future<void> deleteGift(String giftId) async {
    try {
      if (giftId.isEmpty) throw ArgumentError('giftId cannot be empty');

      print('Attempting to delete gift with ID: $giftId'); // Add better logging
      await giftsRef.doc(giftId).delete();
      print('Gift with ID $giftId deleted successfully');
    } catch (e) {
      print('Error deleting gift with ID $giftId: $e');
      rethrow;
    }
  }

  // Generate a unique ID
  String generateUniqueId() {
    return Uuid().v4(); // Using uuid package to generate a version 4 UUID
  }

  // Fetch events owned by the current user
  Future<List<EventModel>> getUserEvents() async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final QuerySnapshot snapshot = await eventsRef
          .where('owner', isEqualTo: userId)
          .limit(100) // Add limit
          .get();

      return snapshot.docs.map((doc) {
        return EventModel.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching user events: $e');
      rethrow;
    }
  }
}