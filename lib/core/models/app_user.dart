import 'package:cloud_firestore/cloud_firestore.dart';

/// The application user profile — deliberately separate from the Firebase
/// Auth identity (which only carries uid/email/credentials) and from any
/// future role-specific profile (Staff, Parent, Student).
///
/// `AppUser.id == FirebaseAuth uid`. A future Staff module will maintain its
/// own staff profile that *references* this user; it must not merge into it.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Same value as the Firebase Auth uid.
  final String id;
  final String email;
  final String displayName;
  final AppUserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == AppUserStatus.active;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('AppUser document ${doc.id} has no data.');
    }
    return AppUser(
      id: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      status: AppUserStatus.fromValue(data['status'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, Object?> toFirestore() => {
        'email': email,
        'displayName': displayName,
        'status': status.value,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}

enum AppUserStatus {
  active,
  disabled;

  String get value => name;

  static AppUserStatus fromValue(String value) =>
      AppUserStatus.values.firstWhere(
        (s) => s.value == value,
        orElse: () => throw ArgumentError('Unknown user status: $value'),
      );
}
