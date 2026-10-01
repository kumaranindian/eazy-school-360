import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/firestore_paths.dart';
import '../../errors/failure_mapper.dart';
import '../audit_log_repository.dart';

class FirebaseAuditLogRepository implements AuditLogRepository {
  FirebaseAuditLogRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.auditLogs);

  @override
  Future<void> record({
    required String actorUserId,
    required String? schoolId,
    required String action,
    required String entityType,
    required String entityId,
  }) async {
    try {
      await _collection.add({
        'actorUserId': actorUserId,
        'schoolId': schoolId,
        'action': action,
        'entityType': entityType,
        'entityId': entityId,
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });
    } catch (error) {
      // Audit logging must never block or crash the primary user action.
      throw mapExceptionToFailure(error);
    }
  }
}
