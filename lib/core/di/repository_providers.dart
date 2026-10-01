import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/authentication/data/firebase_auth_repository.dart';
import '../../features/authentication/domain/auth_repository.dart';
import '../repositories/audit_log_repository.dart';
import '../repositories/firebase/firebase_audit_log_repository.dart';
import '../repositories/firebase/firebase_membership_repository.dart';
import '../repositories/firebase/firebase_school_repository.dart';
import '../repositories/firebase/firebase_user_repository.dart';
import '../repositories/membership_repository.dart';
import '../repositories/school_repository.dart';
import '../repositories/user_repository.dart';
import 'firebase_providers.dart';

/// Single place every feature gets its repositories from — see
/// `docs/architecture/overview.md`. Swapping an implementation (e.g. for a
/// future non-Firebase data source) only requires changing this file.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(ref.watch(firebaseAuthProvider));
});

final schoolRepositoryProvider = Provider<SchoolRepository>((ref) {
  return FirebaseSchoolRepository(ref.watch(firestoreProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepository(ref.watch(firestoreProvider));
});

final membershipRepositoryProvider = Provider<MembershipRepository>((ref) {
  return FirebaseMembershipRepository(ref.watch(firestoreProvider));
});

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  return FirebaseAuditLogRepository(ref.watch(firestoreProvider));
});
