import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class RuyaScreen extends StatefulWidget {
  const RuyaScreen({super.key});

  @override
  State<RuyaScreen> createState() => _RuyaScreenState();
}

class _RuyaScreenState extends State<RuyaScreen> with TickerProviderStateMixin {
  final _dreamController = TextEditingController();
  bool _loading = false;
  String? _result;
  String _dream = '';

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _glowAnimation =
        Tween<double>(begin: 0.3, end: 1.0).animate(_glowController);
  }

  @override
  void dispose() {
    _dreamController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _interpretDream() async {
    if (_dream.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen rüyanızı daha detaylı anlatın'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': AppConstants.claudeApiKey,
          'anthropic-version': '2023-06-01'
        },
        body: jsonEncode({
          'model': 'claude-haiku-4-5-20251001',
          'max_tokens': 600,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Rüya yorumu yap. Rüya: "$_dream"\n\nBu rüyayı hem psikolojik (bilinçaltı sembolleri) hem de mistik (kehanet, mesaj) açıdan yorumla. Rüyadaki sembollerin anlamlarını açıkla ve kişiye ne mesaj verdiğini anlat. Türkçe, 5-6 cümle, mistik ve şiirsel ol, emoji kullan, markdown kullanma.'
            }
          ],
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _result = data['content'][0]['text'] as String;
          _loading = false;
        });
      } else {
        setState(() {
          _result = 'Rüya şu an yorumlanamıyor... 💭';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Evren şu an konuşmuyor... ✨';
        _loading = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _result = null;
      _dream = '';
    });
    _dreamController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppTheme.gold, size: 20),
            onPressed: () => Navigator.pop(context)),
        title: ShaderMask(
          shaderCallback: (bounds) => AppTheme.goldToLilac.createShader(bounds),
          child: const Text('💭 Rüya Yorumu',
              style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('Bilinçaltının Mesajları',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 32),

              // Glow animasyonlu ikon
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.violet
                              .withOpacity(0.3 * _glowAnimation.value),
                          blurRadius: 40,
                          spreadRadius: 15),
                      BoxShadow(
                          color: Colors.indigo
                              .withOpacity(0.2 * _glowAnimation.value),
                          blurRadius: 60,
                          spreadRadius: 25),
                    ],
                  ),
                  child: const Center(
                      child: Text('💭', style: TextStyle(fontSize: 70))),
                ),
              ),
              const SizedBox(height: 20),
              const Text('"Rüyalar ruhun gizli dilidir..."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 32),

              if (_result == null) ...[
                // Rüya metin girişi
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.purple1.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppTheme.purple3.withOpacity(0.4)),
                  ),
                  child: TextField(
                    controller: _dreamController,
                    style: const TextStyle(
                        color: AppTheme.white,
                        fontFamily: 'Nunito',
                        height: 1.6),
                    maxLines: 7,
                    onChanged: (v) => setState(() => _dream = v),
                    decoration: const InputDecoration(
                      hintText:
                          'Rüyanızı buraya anlatın...\n\nNe gördünüz? Kimler vardı? Nasıl hissettiniz? Ne kadar detay verirseniz yorum o kadar güçlü olur.',
                      hintStyle: TextStyle(
                          color: AppTheme.muted, fontSize: 13, height: 1.6),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(20),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Karakter sayacı
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('${_dream.length} karakter',
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          color: AppTheme.muted)),
                ),
                const SizedBox(height: 12),

                // İpucu kutusu
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AppTheme.gold.withOpacity(0.2))),
                  child: const Text(
                      '💡 İpucu: Renkleri, sayıları, tanıdık yüzleri, mekanları ve duygularınızı anlatın. Ne kadar detay o kadar güçlü yorum!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          color: AppTheme.muted,
                          height: 1.5)),
                ),
                const SizedBox(height: 24),

                if (_loading) ...[
                  const CircularProgressIndicator(
                      color: AppTheme.gold, strokeWidth: 2),
                  const SizedBox(height: 16),
                  const Text('Rüyan yorumlanıyor... 💭✨',
                      style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.muted)),
                ] else ...[
                  GestureDetector(
                    onTap: _interpretDream,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF3D1A8E), Color(0xFF7B2FBE)]),
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.violet.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: const Center(
                          child: Text('💭 Rüyamı Yorumla',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 15,
                                  color: Colors.white,
                                  letterSpacing: 1))),
                    ),
                  ),
                ],
              ] else ...[
                // Rüya özeti kutusu
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppTheme.purple3.withOpacity(0.3))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Anlattığınız rüya:',
                            style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 11,
                                color: AppTheme.gold)),
                        const SizedBox(height: 6),
                        Text(
                          _dream.length > 120
                              ? '${_dream.substring(0, 120)}...'
                              : _dream,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              color: AppTheme.muted,
                              fontStyle: FontStyle.italic,
                              height: 1.5),
                        ),
                      ]),
                ),
                const SizedBox(height: 16),

                // Yorum kutusu
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppTheme.purple1.withOpacity(0.8),
                      const Color(0xFF1A0D4A).withOpacity(0.6)
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.violet.withOpacity(0.4)),
                  ),
                  child: Text(_result!,
                      style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                          height: 1.8)),
                ),
                const SizedBox(height: 24),
                const Text('Bu yorumu paylaşmak ister misin?',
                    style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 13,
                        color: AppTheme.gold)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final ps = PostService();
                    await ps.createPost(
                        caption:
                            '"${_result!.substring(0, _result!.length > 80 ? 80 : _result!.length)}..."',
                        fortuneType: 'Rüya Yorumu',
                        fortuneEmoji: '💭',
                        fortuneResult: _result!,
                        shareToFeed: true,
                        shareToProfile: true);
                    if (context.mounted)
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Gönderi paylaşıldı! ✨'),
                          backgroundColor: AppTheme.violet,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))));
                  },
                  child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppTheme.violet, AppTheme.purple3]),
                          borderRadius: BorderRadius.circular(25)),
                      child: const Center(
                          child: Text('✦ Akışta ve Profilde Paylaş',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 13,
                                  color: Colors.white,
                                  letterSpacing: 1)))),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final ps = PostService();
                    await ps.createPost(
                        caption:
                            '"${_result!.substring(0, _result!.length > 80 ? 80 : _result!.length)}..."',
                        fortuneType: 'Rüya Yorumu',
                        fortuneEmoji: '💭',
                        fortuneResult: _result!,
                        shareToFeed: false,
                        shareToProfile: true);
                    if (context.mounted)
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Gönderi paylaşıldı! ✨'),
                          backgroundColor: AppTheme.violet,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))));
                  },
                  child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: AppTheme.violet.withOpacity(0.6)),
                          borderRadius: BorderRadius.circular(25)),
                      child: const Center(
                          child: Text('Sadece Profilimde Paylaş',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 13,
                                  color: AppTheme.white,
                                  letterSpacing: 1)))),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppTheme.muted.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(25)),
                        child: const Center(
                            child: Text('Paylaşma',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.muted,
                                    fontFamily: 'Nunito'))))),
                const SizedBox(height: 10),
                GestureDetector(
                    onTap: _reset,
                    child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppTheme.gold.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(25)),
                        child: const Center(
                            child: Text('🔄 Yeni Rüya Anlat',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.gold,
                                    fontFamily: 'Nunito'))))),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
