import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/firestore_paths.dart';
import '../../errors/failure_mapper.dart';
import '../../models/app_user.dart';
import '../user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.users);

  @override
  Stream<AppUser?> watchUser(String userId) {
    return _collection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    }).handleError((error) => throw mapExceptionToFailure(error));
  }

  @override
  Future<AppUser?> getUser(String userId) async {
    try {
      final doc = await _collection.doc(userId).get();
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    } catch (error) {
      throw mapExceptionToFailure(error);
    }
  }

  @override
  Future<void> ensureUserProfile({
    required String userId,
    required String email,
    required String displayName,
  }) async {
    try {
      final ref = _collection.doc(userId);
      final doc = await ref.get();
      if (doc.exists) return;

      final now = DateTime.now();
      await ref.set({
        'email': email,
        'displayName': displayName,
        'status': 'active',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });
    } catch (error) {
      throw mapExceptionToFailure(error);
    }
  }
}
