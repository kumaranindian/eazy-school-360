import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/firestore_paths.dart';
import '../../errors/failure_mapper.dart';
import '../../models/school.dart';
import '../school_repository.dart';

class FirebaseSchoolRepository implements SchoolRepository {
  FirebaseSchoolRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.schools);

  @override
  Stream<School?> watchSchool(String schoolId) {
    return _collection.doc(schoolId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return School.fromFirestore(doc);
    }).handleError((error) => throw mapExceptionToFailure(error));
  }

  @override
  Future<School?> getSchool(String schoolId) async {
    try {
      final doc = await _collection.doc(schoolId).get();
      if (!doc.exists) return null;
      return School.fromFirestore(doc);
    } catch (error) {
      throw mapExceptionToFailure(error);
    }
  }
}
