import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/firestore_paths.dart';
import '../../errors/failure_mapper.dart';
import '../../models/school_membership.dart';
import '../membership_repository.dart';

class FirebaseMembershipRepository implements MembershipRepository {
  FirebaseMembershipRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.schoolMemberships);

  @override
  Stream<SchoolMembership?> watchActiveMembership(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return SchoolMembership.fromFirestore(snapshot.docs.first);
    }).handleError((error) => throw mapExceptionToFailure(error));
  }
}
