import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Bildirim gönder
  Future<void> sendNotification({
    required String toUid,
    required String type, // 'like', 'comment', 'follow'
    required String postId,
    String? comment,
  }) async {
    final fromUid = _auth.currentUser?.uid;
    if (fromUid == null || fromUid == toUid) return;

    final fromUser = await _firestore.collection('users').doc(fromUid).get();
    final username = fromUser.data()?['username'] ?? '';
    final sign = fromUser.data()?['sign'] ?? '';

    String message = '';
    if (type == 'like') message = 'gönderini beğendi ❤️';
    if (type == 'comment') message = 'yorum yaptı: "$comment" 💬';
    if (type == 'follow') message = 'seni takip etmeye başladı ✨';

    await _firestore.collection('notifications').add({
      'toUid': toUid,
      'fromUid': fromUid,
      'username': username,
      'sign': sign,
      'type': type,
      'message': message,
      'postId': postId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Bildirimleri getir
  Stream<QuerySnapshot> getNotifications() {
    final uid = _auth.currentUser?.uid;
    return _firestore
        .collection('notifications')
        .where('toUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Okunmamış bildirim sayısı
  Stream<int> getUnreadCount() {
    final uid = _auth.currentUser?.uid;
    return _firestore
        .collection('notifications')
        .where('toUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Bildirimi okundu işaretle
  Future<void> markAllAsRead() async {
    final uid = _auth.currentUser?.uid;
    final notifications = await _firestore
        .collection('notifications')
        .where('toUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in notifications.docs) {
      await doc.reference.update({'isRead': true});
    }
  }
}
