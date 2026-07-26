import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> createPost({
    required String caption,
    required String fortuneType,
    required String fortuneEmoji,
    required String fortuneResult,
    bool shareToFeed = true,
    bool shareToProfile = true,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return 'Giriş yapman gerekiyor.';

      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data();

      await _firestore.collection('posts').add({
        'uid': uid,
        'username': userData?['username'] ?? '',
        'name': userData?['name'] ?? '',
        'sign': userData?['sign'] ?? '',
        'caption': caption,
        'fortuneType': fortuneType,
        'fortuneEmoji': fortuneEmoji,
        'fortuneResult': fortuneResult,
        'likes': [],
        'commentCount': 0,
        'shareToFeed': shareToFeed,
        'shareToProfile': shareToProfile,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(uid).update({
        'postCount': FieldValue.increment(1),
      });

      return null;
    } catch (e) {
      return 'Gönderi paylaşılırken hata oluştu.';
    }
  }

  Future<void> toggleLike(String postId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final postRef = _firestore.collection('posts').doc(postId);
    final post = await postRef.get();
    final likes = List<String>.from(post.data()?['likes'] ?? []);

    if (likes.contains(uid)) {
      likes.remove(uid);
    } else {
      likes.add(uid);
    }

    await postRef.update({'likes': likes});
  }

  Future<void> deletePost(String postId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('posts').doc(postId).delete();
    await _firestore.collection('users').doc(uid).update({
      'postCount': FieldValue.increment(-1),
    });
  }

  Future<void> addComment(
      {required String postId, required String comment}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userData = userDoc.data();

    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'uid': uid,
      'username': userData?['username'] ?? '',
      'sign': userData?['sign'] ?? '',
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  Future<void> deleteComment(
      {required String postId, required String commentId}) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }

  // Herkesin gönderileri (Keşfet tabı)
  Stream<QuerySnapshot> getFeedPosts() {
    return _firestore
        .collection('posts')
        .where('shareToFeed', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Sadece takip edilenlerin gönderileri (Akış tabı)
  Future<Stream<QuerySnapshot>> getFollowingPosts() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final following = List<String>.from(userDoc.data()?['following'] ?? []);

    // Kendini de ekle (kendi paylaşımları da görünsün)
    following.add(uid);

    if (following.isEmpty) return const Stream.empty();

    // Firestore 'whereIn' max 30 eleman destekler
    final limited = following.take(30).toList();

    return _firestore
        .collection('posts')
        .where('uid', whereIn: limited)
        .where('shareToFeed', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getProfilePosts(String uid) {
    return _firestore
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .where('shareToProfile', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
