import '../models/school.dart';

abstract interface class SchoolRepository {
  /// Streams a single school by id, or `null` if it doesn't exist / is not
  /// accessible. Access control is enforced by `firestore.rules`, not here.
  Stream<School?> watchSchool(String schoolId);

  Future<School?> getSchool(String schoolId);
}
