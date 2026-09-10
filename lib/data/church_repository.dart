import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:churchkr/data/models.dart';

class ChurchRepository {
  ChurchRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<ParishRecord?> parishByPid(String pid) async {
    final snap = await _db
        .collection('parishes')
        .where('pid', isEqualTo: pid)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    final data = doc.data();
    return ParishRecord(
      id: doc.id,
      name: data['name'] as String? ?? '',
      city: data['city'] as String? ?? '',
      pid: data['pid'] as String? ?? pid,
    );
  }

  Stream<List<ScheduleRecord>> schedulesForParish(DocumentReference parishRef) {
    return _db
        .collection('schedules')
        .where('parishe', isEqualTo: parishRef)
        .snapshots()
        .map((snap) {
      final items = snap.docs.map((doc) {
        final data = doc.data();
        final raw = data['schedule_datetime'];
        DateTime? dateTime;
        if (raw is Timestamp) dateTime = raw.toDate();
        final service = data['services'];
        return ScheduleRecord(
          id: doc.id,
          name: data['name'] as String? ?? '',
          dateTime: dateTime,
          serviceId: service is DocumentReference ? service.id : null,
        );
      }).toList()
        ..sort((a, b) {
          final left = a.dateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          final right = b.dateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          return left.compareTo(right);
        });
      return items;
    });
  }

  Stream<List<ScheduleRecord>> schedulesForPid(String pid) async* {
    final parish = await parishByPid(pid);
    if (parish == null) {
      yield const [];
      return;
    }
    yield* schedulesForParish(parishRef(parish.id));
  }

  DocumentReference parishRef(String documentId) =>
      _db.collection('parishes').doc(documentId);

  Future<ServiceRecord?> serviceById(String id) async {
    final doc = await _db.collection('services').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() ?? {};
    return ServiceRecord(
      id: doc.id,
      nameRu: data['name_ru'] as String? ?? '',
      nameKr: data['name_kr'] as String? ?? '',
      nameEn: data['name_en'] as String? ?? '',
    );
  }
}
