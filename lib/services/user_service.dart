import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser?.uid ?? '';

  Stream<QuerySnapshot> getAllUsers() {
    final myUid = currentUid;
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: myUid)
        .snapshots();
  }

  Future<void> toggleFollow(String targetUid) async {
    final myUid = currentUid;
    if (myUid.isEmpty || myUid == targetUid) return;
    final myRef = _firestore.collection('users').doc(myUid);
    final targetRef = _firestore.collection('users').doc(targetUid);
    final myDoc = await myRef.get();
    final following = List<String>.from(myDoc.data()?['following'] ?? []);
    if (following.contains(targetUid)) {
      await myRef.update({
        'following': FieldValue.arrayRemove([targetUid])
      });
      await targetRef.update({
        'followers': FieldValue.arrayRemove([myUid])
      });
    } else {
      await myRef.update({
        'following': FieldValue.arrayUnion([targetUid])
      });
      await targetRef.update({
        'followers': FieldValue.arrayUnion([myUid])
      });
    }
  }

  Future<bool> isFollowing(String targetUid) async {
    final myUid = currentUid;
    if (myUid.isEmpty) return false;
    final doc = await _firestore.collection('users').doc(myUid).get();
    final following = List<String>.from(doc.data()?['following'] ?? []);
    return following.contains(targetUid);
  }

  Future<void> toggleBlock(String targetUid) async {
    final myUid = currentUid;
    if (myUid.isEmpty || myUid == targetUid) return;
    final myRef = _firestore.collection('users').doc(myUid);
    final myDoc = await myRef.get();
    final blocked = List<String>.from(myDoc.data()?['blocked'] ?? []);
    if (blocked.contains(targetUid)) {
      await myRef.update({
        'blocked': FieldValue.arrayRemove([targetUid])
      });
    } else {
      await myRef.update({
        'blocked': FieldValue.arrayUnion([targetUid]),
        'following': FieldValue.arrayRemove([targetUid]),
      });
      await _firestore.collection('users').doc(targetUid).update({
        'followers': FieldValue.arrayRemove([myUid])
      });
    }
  }

  Future<bool> isBlocked(String targetUid) async {
    final myUid = currentUid;
    if (myUid.isEmpty) return false;
    final doc = await _firestore.collection('users').doc(myUid).get();
    final blocked = List<String>.from(doc.data()?['blocked'] ?? []);
    return blocked.contains(targetUid);
  }

  Future<bool> isBlockedByUser(String targetUid) async {
    final myUid = currentUid;
    if (myUid.isEmpty) return false;
    final doc = await _firestore.collection('users').doc(targetUid).get();
    final blocked = List<String>.from(doc.data()?['blocked'] ?? []);
    return blocked.contains(myUid);
  }

  // İsim, soyisim, @kullanıcıadı veya email ile arama
  Future<List<Map<String, dynamic>>> searchUsersMulti(String query) async {
    final myUid = currentUid;
    if (query.isEmpty) return [];

    final q = query.toLowerCase().trim();
    final Set<String> foundUids = {};
    final List<Map<String, dynamic>> results = [];

    // 1. usernameLower ile ara
    final byUsername = await _firestore
        .collection('users')
        .where('usernameLower', isGreaterThanOrEqualTo: q)
        .where('usernameLower', isLessThanOrEqualTo: '$q\uf8ff')
        .limit(20)
        .get();

    // 2. nameLower ile ara
    final byName = await _firestore
        .collection('users')
        .where('nameLower', isGreaterThanOrEqualTo: q)
        .where('nameLower', isLessThanOrEqualTo: '$q\uf8ff')
        .limit(20)
        .get();

    // 3. surnameLower ile ara
    final bySurname = await _firestore
        .collection('users')
        .where('surnameLower', isGreaterThanOrEqualTo: q)
        .where('surnameLower', isLessThanOrEqualTo: '$q\uf8ff')
        .limit(20)
        .get();

    // 4. email ile ara
    final byEmail = await _firestore
        .collection('users')
        .where('email', isEqualTo: q)
        .limit(5)
        .get();

    for (final doc in [
      ...byUsername.docs,
      ...byName.docs,
      ...bySurname.docs,
      ...byEmail.docs
    ]) {
      final data = doc.data() as Map<String, dynamic>;
      final uid = data['uid'] ?? '';
      if (uid != myUid && !foundUids.contains(uid)) {
        foundUids.add(uid);
        results.add(data);
      }
    }

    return results;
  }

  // Eski stream tabanlı arama (geriye dönük uyumluluk)
  Stream<QuerySnapshot> searchUsers(String query) {
    final myUid = currentUid;
    if (query.isEmpty) {
      return _firestore
          .collection('users')
          .where('uid', isNotEqualTo: myUid)
          .snapshots();
    }
    return _firestore
        .collection('users')
        .where('usernameLower', isGreaterThanOrEqualTo: query.toLowerCase())
        .where('usernameLower',
            isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
        .snapshots();
  }
}
