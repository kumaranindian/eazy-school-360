import '../models/school_membership.dart';

abstract interface class MembershipRepository {
  /// Streams the current active membership for [userId], or `null` if the
  /// user has none. Phase 1 assumes a single active membership per user.
  Stream<SchoolMembership?> watchActiveMembership(String userId);
}
