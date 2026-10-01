import 'package:cloud_firestore/cloud_firestore.dart';

/// A school — the primary tenant in EazySchool 360.
///
/// Platform-owned: created and managed by Platform Admins. Every
/// tenant-owned resource (users' school memberships, and future modules
/// such as students/staff/fees) is scoped to a [School.id].
///
/// Intentionally minimal for Phase 1 — branding, detailed profile, branches,
/// and academic years are later features.
class School {
  const School({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;

  /// A short, unique, human-readable code (e.g. `EZS001`). Immutable once set.
  final String code;

  final SchoolStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == SchoolStatus.active;

  factory School.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('School document ${doc.id} has no data.');
    }
    return School(
      id: doc.id,
      name: data['name'] as String,
      code: data['code'] as String,
      status: SchoolStatus.fromValue(data['status'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, Object?> toFirestore() => {
        'name': name,
        'code': code,
        'status': status.value,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}

enum SchoolStatus {
  active,
  suspended;

  String get value => name;

  static SchoolStatus fromValue(String value) =>
      SchoolStatus.values.firstWhere(
        (s) => s.value == value,
        orElse: () => throw ArgumentError('Unknown school status: $value'),
      );
}
