import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/chat_service.dart';
import 'package:falcim/screens/chat_detail_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  String _getSignEmoji(String sign) {
    final signs = {
      'Koç': '♈',
      'Boğa': '♉',
      'İkizler': '♊',
      'Yengeç': '♋',
      'Aslan': '♌',
      'Başak': '♍',
      'Terazi': '♎',
      'Akrep': '♏',
      'Yay': '♐',
      'Oğlak': '♑',
      'Kova': '♒',
      'Balık': '♓',
    };
    return signs[sign] ?? '⭐';
  }

  String _timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final diff = now.difference(timestamp.toDate());
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inHours < 1) return '${diff.inMinutes}dk';
    if (diff.inDays < 1) return '${diff.inHours}sa';
    if (diff.inDays < 7) return '${diff.inDays}g';
    return '${diff.inDays ~/ 7}h';
  }

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.deep,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: chatService.getChats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.gold),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('💬', style: TextStyle(fontSize: 50)),
                          SizedBox(height: 12),
                          Text(
                            'Henüz mesaj yok',
                            style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 14,
                              color: AppTheme.muted,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Kullanıcı profilinden mesaj gönderebilirsin',
                            style: TextStyle(
                              fontFamily: 'Cormorant Garamond',
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                      final participants =
                          List<String>.from(data['participants'] ?? []);
                      final otherUid = participants
                          .firstWhere((uid) => uid != myUid, orElse: () => '');

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(otherUid)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const SizedBox();
                          }
                          final userData = userSnapshot.data!.data()
                              as Map<String, dynamic>?;
                          if (userData == null) return const SizedBox();

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(
                                    otherUid: otherUid,
                                    otherUserData: userData,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.purple1.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                    color: AppTheme.purple3.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.gold,
                                          AppTheme.violet
                                        ],
                                      ),
                                    ),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.purple2,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getSignEmoji(userData['sign'] ?? ''),
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userData['username'] ?? '',
                                          style: const TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.white,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          data['lastMessage'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 12,
                                            color: AppTheme.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _timeAgo(
                                        data['lastMessageTime'] as Timestamp?),
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 11,
                                      color: AppTheme.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.purple1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.purple3.withOpacity(0.4)),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: AppTheme.white, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.goldToLilac.createShader(bounds),
            child: const Text(
              'Mesajlar',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
