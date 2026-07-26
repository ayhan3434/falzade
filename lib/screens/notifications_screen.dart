import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.markAllAsRead();
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

  String _timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final diff = now.difference(timestamp.toDate());
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inHours < 1) return '${diff.inMinutes}dk önce';
    if (diff.inDays < 1) return '${diff.inHours}sa önce';
    if (diff.inDays < 7) return '${diff.inDays}g önce';
    return '${diff.inDays ~/ 7}h önce';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deep,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildList()),
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
              'Bildirimler',
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

  Widget _buildList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _notificationService.getNotifications(),
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
                Text('🔔', style: TextStyle(fontSize: 50)),
                SizedBox(height: 12),
                Text(
                  'Henüz bildirim yok',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 14,
                    color: AppTheme.muted,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Etkileşimler burada görünecek',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final isRead = data['isRead'] ?? true;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isRead
                    ? AppTheme.purple1.withOpacity(0.3)
                    : AppTheme.purple1.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isRead
                      ? AppTheme.purple3.withOpacity(0.2)
                      : AppTheme.violet.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.purple2, AppTheme.violet],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getSignEmoji(data['sign'] ?? ''),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${data['username']} ',
                                style: const TextStyle(
                                  color: AppTheme.gold,
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: data['message'] ?? '',
                                style: const TextStyle(
                                  color: AppTheme.white,
                                  fontFamily: 'Nunito',
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _timeAgo(data['createdAt'] as Timestamp?),
                          style: const TextStyle(
                            color: AppTheme.muted,
                            fontFamily: 'Nunito',
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.violet,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
