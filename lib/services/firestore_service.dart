import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- PLACES ---
  Future<List<Place>> getPlaces() async {
    final snapshot = await _db.collection('places').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // ensure ID matches the document ID
      return Place.fromMap(data);
    }).toList();
  }

  // --- LECTURERS ---
  Future<List<Lecturer>> getLecturers() async {
    final snapshot = await _db.collection('lecturers').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Lecturer.fromMap(data);
    }).toList();
  }

  // --- BUS SCHEDULES ---
  Future<List<BusScheduleEntry>> getBusSchedules() async {
    final snapshot = await _db.collection('bus_schedules').orderBy('time').get(); // adjust ordering if needed
    return snapshot.docs.map((doc) {
      return BusScheduleEntry.fromMap(doc.data());
    }).toList();
  }

  // --- BUS ROUTES ---
  Future<List<BusRoute>> getBusRoutes() async {
    final snapshot = await _db.collection('bus_routes').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return BusRoute.fromMap(data);
    }).toList();
  }

}
