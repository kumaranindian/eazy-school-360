import 'package:cloud_firestore/cloud_firestore.dart';

import 'role.dart';

/// Links a user to a school with a role — the authorization layer's source
/// of truth for tenant membership.
///
/// Membership documents are never writable by clients (see
/// `firestore.rules`): role assignment is a privileged, platform-admin-only
/// (or Cloud Function) operation. The client must never be trusted to
/// self-assign a school or role.
///
/// Phase 1 models a single active membership per user. [MembershipRepository]
/// is still shaped as a query over a collection (not a single field on
/// [AppUser]) so multi-school support can be added later without a data
/// migration — see `docs/architecture/multi-tenancy.md`.
class SchoolMembership {
  const SchoolMembership({
    required this.id,
    required this.userId,
    required this.schoolId,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;

  /// Null for a platform admin, who is not scoped to a single school.
  final String? schoolId;

  final AppRole role;
  final MembershipStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == MembershipStatus.active;

  factory SchoolMembership.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw StateError('SchoolMembership document ${doc.id} has no data.');
    }
    return SchoolMembership(
      id: doc.id,
      userId: data['userId'] as String,
      schoolId: data['schoolId'] as String?,
      role: AppRole.fromValue(data['role'] as String),
      status: MembershipStatus.fromValue(data['status'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, Object?> toFirestore() => {
        'userId': userId,
        'schoolId': schoolId,
        'role': role.value,
        'status': status.value,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}

enum MembershipStatus {
  active,
  revoked;

  String get value => name;

  static MembershipStatus fromValue(String value) =>
      MembershipStatus.values.firstWhere(
        (s) => s.value == value,
        orElse: () => throw ArgumentError('Unknown membership status: $value'),
      );
}
