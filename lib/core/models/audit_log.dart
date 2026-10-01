import 'package:cloud_firestore/cloud_firestore.dart';

/// Foundation audit log record.
///
/// Append-only by design (see `firestore.rules` — update/delete are always
/// denied). This is infrastructure for later modules to write into; there is
/// no audit UI in Phase 1.
class AuditLog {
  const AuditLog({
    required this.id,
    required this.actorUserId,
    required this.schoolId,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.timestamp,
  });

  final String id;
  final String actorUserId;

  /// Null for a platform-level action not scoped to a school.
  final String? schoolId;

  /// A short action code, e.g. `SCHOOL_CREATED`, `MEMBERSHIP_GRANTED`.
  final String action;

  /// The kind of entity affected, e.g. `school`, `schoolMembership`.
  final String entityType;
  final String entityId;
  final DateTime timestamp;

  factory AuditLog.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('AuditLog document ${doc.id} has no data.');
    }
    return AuditLog(
      id: doc.id,
      actorUserId: data['actorUserId'] as String,
      schoolId: data['schoolId'] as String?,
      action: data['action'] as String,
      entityType: data['entityType'] as String,
      entityId: data['entityId'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, Object?> toFirestore() => {
        'actorUserId': actorUserId,
        'schoolId': schoolId,
        'action': action,
        'entityType': entityType,
        'entityId': entityId,
        'timestamp': Timestamp.fromDate(timestamp),
      };
}
