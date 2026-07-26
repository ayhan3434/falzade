import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class KabalaScreen extends StatefulWidget {
  const KabalaScreen({super.key});
  @override
  State<KabalaScreen> createState() => _KabalaScreenState();
}

class _KabalaScreenState extends State<KabalaScreen>
    with TickerProviderStateMixin {
  final _intentController = TextEditingController();
  String _intent = '';
  bool _loading = false;
  String? _result;
  Map<String, dynamic>? _reading;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  static const _sefirots = [
    {'name': 'Keter', 'emoji': '👑', 'meaning': 'İlahi irade ve saf bilinç'},
    {'name': 'Hokma', 'emoji': '💡', 'meaning': 'Bilgelik ve ilham'},
    {'name': 'Bina', 'emoji': '🧠', 'meaning': 'Anlayış ve form'},
    {'name': 'Hesed', 'emoji': '💙', 'meaning': 'Merhamet ve sevgi'},
    {'name': 'Gevura', 'emoji': '🔥', 'meaning': 'Güç ve disiplin'},
    {'name': 'Tiferet', 'emoji': '☀️', 'meaning': 'Güzellik ve denge'},
    {'name': 'Netzah', 'emoji': '💚', 'meaning': 'Zafer ve doğa'},
    {'name': 'Hod', 'emoji': '🌟', 'meaning': 'İhtişam ve iletişim'},
    {'name': 'Yesod', 'emoji': '🌙', 'meaning': 'Temel ve bağlantı'},
    {'name': 'Malkut', 'emoji': '🌍', 'meaning': 'Krallık ve maddi dünya'},
  ];

  static const _hebrewLetters = [
    'א',
    'ב',
    'ג',
    'ד',
    'ה',
    'ו',
    'ז',
    'ח',
    'ט',
    'י'
  ];

  void _generateReading() {
    final random = Random();
    final sefirot = List.from(_sefirots)..shuffle(random);
    _reading = {
      'mainSefirot': sefirot[0],
      'secondSefirot': sefirot[1],
      'letter': _hebrewLetters[random.nextInt(_hebrewLetters.length)],
      'path': random.nextInt(22) + 1,
    };
  }

  @override
  void initState() {
    super.initState();
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _glowAnimation =
        Tween<double>(begin: 0.4, end: 1.0).animate(_glowController);
    _rotateController =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();
    _rotateAnimation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_rotateController);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _rotateController.dispose();
    _intentController.dispose();
    super.dispose();
  }

  Future<void> _getReading() async {
    if (_intent.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lütfen niyetinizi yazın'),
          backgroundColor: Colors.redAccent));
      return;
    }
    _generateReading();
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
                  'Kabala\'nın Hayat Ağacı\'na göre fal yorumu yap.\n\nNiyet: $_intent\nAna Sefirot: ${_reading!['mainSefirot']['name']} - ${_reading!['mainSefirot']['meaning']}\nİkincil Sefirot: ${_reading!['secondSefirot']['name']} - ${_reading!['secondSefirot']['meaning']}\nİbrani Harf: ${_reading!['letter']}\nYol Numarası: ${_reading!['path']}\n\nBu Kabalistik sembolleri niyetle ilişkilendirerek mistik ve şiirsel bir yorum yap. Kişinin ruhsal yolculuğu hakkında bilgelik ver. Türkçe, 6-7 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Hayat Ağacı şu an sessiz... 🌳';
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
      _intent = '';
      _result = null;
      _reading = null;
    });
    _intentController.clear();
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
            shaderCallback: (bounds) =>
                AppTheme.goldToLilac.createShader(bounds),
            child: const Text('🔯 Kabala Falı',
                style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1))),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Text('Hayat Ağacının Gizemi',
                style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted)),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: Listenable.merge([_glowAnimation, _rotateAnimation]),
              builder: (context, child) =>
                  Stack(alignment: Alignment.center, children: [
                Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppTheme.gold
                                    .withOpacity(0.2 * _glowAnimation.value),
                                width: 1)))),
                Transform.rotate(
                    angle: -_rotateAnimation.value * 0.5,
                    child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF1565C0)
                                    .withOpacity(0.3 * _glowAnimation.value),
                                width: 1)))),
                Container(
                    width: 85,
                    height: 85,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, boxShadow: [
                      BoxShadow(
                          color: AppTheme.gold
                              .withOpacity(0.3 * _glowAnimation.value),
                          blurRadius: 30,
                          spreadRadius: 10),
                      BoxShadow(
                          color: const Color(0xFF1565C0)
                              .withOpacity(0.2 * _glowAnimation.value),
                          blurRadius: 50,
                          spreadRadius: 20)
                    ]),
                    child: const Center(
                        child: Text('🔯', style: TextStyle(fontSize: 55)))),
              ]),
            ),
            const SizedBox(height: 16),
            const Text(
                '"Hayat Ağacı\'nın 10 Sefirot\'u sana rehberlik ediyor..."',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted,
                    height: 1.5)),
            const SizedBox(height: 24),
            if (_result == null) ...[
              // Sefirot önizleme
              SizedBox(
                height: 50,
                child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _sefirots
                        .map((s) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: AppTheme.purple1.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppTheme.gold.withOpacity(0.2))),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(s['emoji'] as String,
                                        style: const TextStyle(fontSize: 14)),
                                    const SizedBox(width: 4),
                                    Text(s['name'] as String,
                                        style: const TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 10,
                                            color: AppTheme.white)),
                                  ]),
                            ))
                        .toList()),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                    color: AppTheme.purple1.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppTheme.purple3.withOpacity(0.4))),
                child: TextField(
                  controller: _intentController,
                  style: const TextStyle(
                      color: AppTheme.white, fontFamily: 'Nunito'),
                  maxLines: 3,
                  onChanged: (v) => setState(() => _intent = v),
                  decoration: const InputDecoration(
                    hintText:
                        'Niyetinizi veya sorunuzu yazın...\n(Ruhsal yolculuğunuz hakkında ne öğrenmek istiyorsunuz?)',
                    hintStyle: TextStyle(
                        color: AppTheme.muted, fontSize: 12, height: 1.5),
                    prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(Icons.auto_awesome,
                            color: AppTheme.gold, size: 20)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_loading) ...[
                const CircularProgressIndicator(
                    color: AppTheme.gold, strokeWidth: 2),
                const SizedBox(height: 12),
                const Text('Hayat Ağacı yorumlanıyor... 🔯✨',
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
              ] else
                GestureDetector(
                    onTap: _getReading,
                    child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFF1565C0), AppTheme.violet]),
                            borderRadius: BorderRadius.circular(27),
                            boxShadow: [
                              BoxShadow(
                                  color: AppTheme.violet.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5))
                            ]),
                        child: const Center(
                            child: Text('🔯 Hayat Ağacına Sor',
                                style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 15,
                                    color: Colors.white,
                                    letterSpacing: 1))))),
            ] else ...[
              if (_reading != null) ...[
                Row(children: [
                  Expanded(
                      child: _buildSefirotCard(
                          _reading!['mainSefirot'], 'Ana Sefirot')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _buildSefirotCard(
                          _reading!['secondSefirot'], 'İkincil Sefirot')),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppTheme.gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppTheme.gold.withOpacity(0.3))),
                    child: Column(children: [
                      Text(_reading!['letter'] as String,
                          style: const TextStyle(
                              fontSize: 32,
                              color: AppTheme.gold,
                              fontWeight: FontWeight.bold)),
                      const Text('İbrani Harf',
                          style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 9,
                              color: AppTheme.muted)),
                    ]),
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF1565C0).withOpacity(0.3))),
                    child: Column(children: [
                      Text('${_reading!['path']}. Yol',
                          style: const TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 18,
                              color: Color(0xFF42A5F5),
                              fontWeight: FontWeight.bold)),
                      const Text('Hayat Ağacı Yolu',
                          style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 9,
                              color: AppTheme.muted)),
                    ]),
                  )),
                ]),
                const SizedBox(height: 16),
              ],
              _buildResultSection(_result!, 'Kabala Falı', '🔯'),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _buildSefirotCard(Map<String, dynamic> sefirot, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppTheme.purple1.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.gold.withOpacity(0.2))),
      child: Column(children: [
        Text(sefirot['emoji'] as String, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Cinzel', fontSize: 8, color: AppTheme.muted)),
        Text(sefirot['name'] as String,
            style: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 12,
                color: AppTheme.gold,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(sefirot['meaning'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Nunito', fontSize: 9, color: AppTheme.muted)),
      ]),
    );
  }

  Widget _buildResultSection(String result, String fortuneType, String emoji) {
    return Column(children: [
      Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFF1565C0).withOpacity(0.1),
                AppTheme.purple1.withOpacity(0.6)
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: const Color(0xFF1565C0).withOpacity(0.3))),
          child: Text(result,
              style: const TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                  height: 1.8))),
      const SizedBox(height: 24),
      const Text('Bu yorumu paylaşmak ister misin?',
          style: TextStyle(
              fontFamily: 'Cinzel', fontSize: 13, color: AppTheme.gold)),
      const SizedBox(height: 12),
      GestureDetector(
          onTap: () async {
            final ps = PostService();
            await ps.createPost(
                caption:
                    '"${result.substring(0, result.length > 80 ? 80 : result.length)}..."',
                fortuneType: fortuneType,
                fortuneEmoji: emoji,
                fortuneResult: result,
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
                          letterSpacing: 1))))),
      const SizedBox(height: 10),
      GestureDetector(
          onTap: () async {
            final ps = PostService();
            await ps.createPost(
                caption:
                    '"${result.substring(0, result.length > 80 ? 80 : result.length)}..."',
                fortuneType: fortuneType,
                fortuneEmoji: emoji,
                fortuneResult: result,
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
                  border: Border.all(color: AppTheme.violet.withOpacity(0.6)),
                  borderRadius: BorderRadius.circular(25)),
              child: const Center(
                  child: Text('Sadece Profilimde Paylaş',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 13,
                          color: AppTheme.white,
                          letterSpacing: 1))))),
      const SizedBox(height: 10),
      GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.muted.withOpacity(0.3)),
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
                  border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(25)),
              child: const Center(
                  child: Text('🔄 Yeni Fal',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.gold,
                          fontFamily: 'Nunito'))))),
      const SizedBox(height: 20),
    ]);
  }
}
