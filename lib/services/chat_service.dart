import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<void> sendMessage({
    required String toUid,
    required String message,
  }) async {
    final fromUid = _auth.currentUser?.uid;
    if (fromUid == null) return;

    final chatId = _getChatId(fromUid, toUid);

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'fromUid': fromUid,
      'toUid': toUid,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    await _firestore.collection('chats').doc(chatId).set({
      'participants': [fromUid, toUid],
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageFrom': fromUid,
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getMessages(String otherUid) {
    final myUid = _auth.currentUser?.uid ?? '';
    final chatId = _getChatId(myUid, otherUid);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // Sıralama olmadan getir - index sorunu çözer
  Stream<QuerySnapshot> getChats() {
    final uid = _auth.currentUser?.uid;
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots();
  }

  Stream<int> getUnreadCount() {
    final uid = _auth.currentUser?.uid;
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .asyncMap((snapshot) async {
      int total = 0;
      for (final doc in snapshot.docs) {
        final unread = await _firestore
            .collection('chats')
            .doc(doc.id)
            .collection('messages')
            .where('toUid', isEqualTo: uid)
            .where('isRead', isEqualTo: false)
            .get();
        total += unread.docs.length;
      }
      return total;
    });
  }

  Future<void> markAsRead(String otherUid) async {
    final myUid = _auth.currentUser?.uid ?? '';
    final chatId = _getChatId(myUid, otherUid);
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('toUid', isEqualTo: myUid)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in messages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }
}
