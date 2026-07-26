import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/chat_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String otherUid;
  final Map<String, dynamic> otherUserData;

  const ChatDetailScreen({
    super.key,
    required this.otherUid,
    required this.otherUserData,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _chatService = ChatService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late String _myUid;

  @override
  void initState() {
    super.initState();
    _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _chatService.markAsRead(widget.otherUid);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final message = _messageController.text.trim();
    _messageController.clear();
    await _chatService.sendMessage(
      toUid: widget.otherUid,
      message: message,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.otherUserData['username'] ?? '';
    final sign = widget.otherUserData['sign'] ?? '';
    final signEmoji = _getSignEmoji(sign);

    return Scaffold(
      backgroundColor: AppTheme.deep,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, username, signEmoji, sign),
            Expanded(child: _buildMessages()),
            _buildInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, String username, String signEmoji, String sign) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.purple1.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(color: AppTheme.purple3.withOpacity(0.3)),
        ),
      ),
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
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.gold, AppTheme.violet],
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.purple2,
              ),
              child: Center(
                child: Text(signEmoji, style: const TextStyle(fontSize: 18)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
                Text(
                  '$signEmoji $sign Burcu',
                  style: const TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.gold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.otherUid),
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
                Text('✨', style: TextStyle(fontSize: 40)),
                SizedBox(height: 12),
                Text(
                  'Henüz mesaj yok',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 13,
                    color: AppTheme.muted,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'İlk mesajı sen gönder!',
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

        final messages = snapshot.data!.docs;
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final data = messages[index].data() as Map<String, dynamic>;
            final isMe = data['fromUid'] == _myUid;
            return _buildMessageBubble(
              data['message'] ?? '',
              isMe,
              data['createdAt'] as Timestamp?,
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(String message, bool isMe, Timestamp? timestamp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isMe
                  ? const LinearGradient(
                      colors: [AppTheme.violet, AppTheme.purple3],
                    )
                  : null,
              color: isMe ? null : AppTheme.purple1,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              border: isMe
                  ? null
                  : Border.all(color: AppTheme.purple3.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontFamily: 'Nunito',
                    fontSize: 14,
                  ),
                ),
                if (timestamp != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      color: AppTheme.white.withOpacity(0.5),
                      fontFamily: 'Nunito',
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.deep,
        border: Border(
          top: BorderSide(color: AppTheme.purple3.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.purple1,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.purple3.withOpacity(0.4)),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(
                    color: AppTheme.white, fontFamily: 'Nunito'),
                decoration: const InputDecoration(
                  hintText: 'Mesaj yaz...',
                  hintStyle:
                      TextStyle(color: AppTheme.muted, fontFamily: 'Nunito'),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.violet, AppTheme.purple3],
                ),
                borderRadius: BorderRadius.circular(23),
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
