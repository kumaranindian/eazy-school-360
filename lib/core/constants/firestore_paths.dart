/// Firestore top-level collection names, centralized so repositories and
/// Cloud Functions / security rules documentation stay in sync.
abstract final class FirestorePaths {
  static const schools = 'schools';
  static const users = 'users';
  static const schoolMemberships = 'schoolMemberships';
  static const roles = 'roles';
  static const auditLogs = 'auditLogs';
}
