import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/event_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addEvent(EventModel event) async {
    await _db.collection('events').add(event.toJson());
  }

  Stream<List<EventModel>> getEvents() {
    return _db.collection('events').snapshots().map(
            (snapshot) => snapshot.docs.map((doc) => EventModel.fromJson(doc.data(), id: doc.id)).toList());
  }

  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }
}