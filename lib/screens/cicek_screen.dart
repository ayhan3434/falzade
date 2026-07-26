import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class CicekScreen extends StatefulWidget {
  const CicekScreen({super.key});
  @override
  State<CicekScreen> createState() => _CicekScreenState();
}

class _CicekScreenState extends State<CicekScreen>
    with TickerProviderStateMixin {
  final _intentController = TextEditingController();
  String _intent = '';
  bool _loading = false;
  bool _plucking = false;
  String? _result;
  Map<String, dynamic>? _reading;
  int _pluckedCount = 0;
  List<bool> _petals = [];

  late AnimationController _bloomController;
  late Animation<double> _bloomAnimation;
  late AnimationController _swayController;
  late Animation<double> _swayAnimation;

  static const _cicekler = [
    {'ad': 'Gül', 'emoji': '🌹', 'anlam': 'Aşk ve tutku', 'color': 0xFFB71C1C},
    {
      'ad': 'Papatya',
      'emoji': '🌼',
      'anlam': 'Saflık ve umut',
      'color': 0xFFF9A825
    },
    {
      'ad': 'Menekşe',
      'emoji': '💜',
      'anlam': 'Ruhsallık ve sezgi',
      'color': 0xFF6A1B9A
    },
    {
      'ad': 'Lale',
      'emoji': '🌷',
      'anlam': 'Mükemmellik ve güzellik',
      'color': 0xFFE91E63
    },
    {
      'ad': 'Pamuklale',
      'emoji': '🌸',
      'anlam': 'Geçicilik ve değişim',
      'color': 0xFFF48FB1
    },
    {
      'ad': 'Ayçiçeği',
      'emoji': '🌻',
      'anlam': 'Neşe ve sadakat',
      'color': 0xFFFF8F00
    },
  ];

  void _generateReading() {
    final random = Random();
    final cicek = _cicekler[random.nextInt(_cicekler.length)];
    final totalPetals = 5 + random.nextInt(4); // 5-8 yaprak
    _pluckedCount = 0;
    _petals = List.generate(totalPetals, (_) => true);
    _reading = {
      'cicek': cicek,
      'totalPetals': totalPetals,
      'sonYaprak': totalPetals % 2 == 1 ? 'EVET ❤️' : 'HAYIR 💔',
    };
  }

  @override
  void initState() {
    super.initState();
    _bloomController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _bloomAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(parent: _bloomController, curve: Curves.easeInOut));
    _swayController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _swayAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
        CurvedAnimation(parent: _swayController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bloomController.dispose();
    _swayController.dispose();
    _intentController.dispose();
    super.dispose();
  }

  void _pluckPetal() {
    if (_reading == null || _pluckedCount >= _petals.length) return;
    setState(() {
      _petals[_pluckedCount] = false;
      _pluckedCount++;
    });
    if (_pluckedCount >= _petals.length) _fetchReading();
  }

  Future<void> _fetchReading() async {
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
                  'Çiçek falı yorumu yap.\n\nNiyet: $_intent\nSeçilen Çiçek: ${_reading!['cicek']['ad']} ${_reading!['cicek']['emoji']} - ${_reading!['cicek']['anlam']}\nToplam Yaprak: ${_reading!['totalPetals']}\nSon Yaprak Cevabı: ${_reading!['sonYaprak']}\n\nGeleneksel "seviyor, sevmiyor" çiçek falını niyetle ilişkilendirerek yorumla. Çiçeğin anlamını ve son yaprağın mesajını mistik şekilde aktar. Türkçe, 5-6 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Çiçek şu an sessiz... 🌸';
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

  void _startReading() {
    if (_intent.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lütfen niyetinizi yazın'),
          backgroundColor: Colors.redAccent));
      return;
    }
    _generateReading();
    setState(() => _plucking = true);
  }

  void _reset() {
    setState(() {
      _intent = '';
      _result = null;
      _reading = null;
      _plucking = false;
      _pluckedCount = 0;
      _petals = [];
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
            child: const Text('🌸 Çiçek Falı',
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
            const Text('Yaprakların Gizemi',
                style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted)),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: Listenable.merge([_bloomAnimation, _swayAnimation]),
              builder: (context, child) => Transform.rotate(
                angle: _swayAnimation.value,
                child: Transform.scale(
                    scale: _bloomAnimation.value,
                    child: Container(
                        width: 120,
                        height: 120,
                        decoration:
                            BoxDecoration(shape: BoxShape.circle, boxShadow: [
                          BoxShadow(
                              color: const Color(0xFFE91E63)
                                  .withOpacity(0.3 * _bloomAnimation.value),
                              blurRadius: 40,
                              spreadRadius: 10)
                        ]),
                        child: Center(
                            child: Text(
                                _reading != null
                                    ? _reading!['cicek']['emoji'] as String
                                    : '🌸',
                                style: const TextStyle(fontSize: 75))))),
              ),
            ),
            const SizedBox(height: 16),
            const Text('"Seviyor... sevmiyor... seviyor..."',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted)),
            const SizedBox(height: 24),
            if (!_plucking && _result == null) ...[
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
                  maxLines: 2,
                  onChanged: (v) => setState(() => _intent = v),
                  decoration: const InputDecoration(
                    hintText:
                        'Niyetinizi yazın...\n(Aklınızdaki kişi veya soru)',
                    hintStyle: TextStyle(
                        color: AppTheme.muted, fontSize: 12, height: 1.5),
                    prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 24),
                        child: Icon(Icons.favorite_border,
                            color: AppTheme.gold, size: 20)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                  onTap: _startReading,
                  child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFAD1457), Color(0xFF6A1B9A)]),
                          borderRadius: BorderRadius.circular(27),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFFE91E63).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5))
                          ]),
                      child: const Center(
                          child: Text('🌸 Çiçeği Seç',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 15,
                                  color: Colors.white,
                                  letterSpacing: 1))))),
            ] else if (_plucking && _result == null && !_loading) ...[
              // Yaprak koparma
              Text('${_reading!['cicek']['ad']} seçildi!',
                  style: const TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 14,
                      color: AppTheme.gold)),
              const SizedBox(height: 8),
              Text('Kalan yaprak: ${_petals.where((p) => p).length}',
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      color: AppTheme.muted)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                    _petals.length,
                    (i) => AnimatedOpacity(
                          opacity: _petals[i] ? 1.0 : 0.2,
                          duration: const Duration(milliseconds: 300),
                          child: Text(_reading!['cicek']['emoji'] as String,
                              style: const TextStyle(fontSize: 28)),
                        )),
              ),
              const SizedBox(height: 16),
              Text(
                  _pluckedCount % 2 == 0
                      ? '"Seviyor... 💚"'
                      : '"Sevmiyor... 🔴"',
                  style: const TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.white)),
              const SizedBox(height: 20),
              GestureDetector(
                  onTap: _pluckPetal,
                  child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFAD1457), Color(0xFF6A1B9A)]),
                          borderRadius: BorderRadius.circular(27)),
                      child: const Center(
                          child: Text('🌸 Yaprak Kopar',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 15,
                                  color: Colors.white,
                                  letterSpacing: 1))))),
            ] else if (_loading) ...[
              const CircularProgressIndicator(
                  color: AppTheme.gold, strokeWidth: 2),
              const SizedBox(height: 12),
              const Text('Son yaprak konuşuyor... 🌸✨',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
            ] else if (_result != null) ...[
              if (_reading != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Color(_reading!['cicek']['color'] as int)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Color(_reading!['cicek']['color'] as int)
                              .withOpacity(0.3))),
                  child: Row(children: [
                    Text(_reading!['cicek']['emoji'] as String,
                        style: const TextStyle(fontSize: 40)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Son Yaprak Cevabı:',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 10,
                                  color: Color(
                                      _reading!['cicek']['color'] as int))),
                          Text(_reading!['sonYaprak'] as String,
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 18,
                                  color:
                                      Color(_reading!['cicek']['color'] as int),
                                  fontWeight: FontWeight.bold)),
                          Text('${_reading!['totalPetals']} yaprak koparıldı',
                              style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 10,
                                  color: AppTheme.muted)),
                        ])),
                  ]),
                ),
              const SizedBox(height: 16),
              _buildResultSection(_result!, 'Çiçek Falı', '🌸'),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _buildResultSection(String result, String fortuneType, String emoji) {
    return Column(children: [
      Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFFAD1457).withOpacity(0.08),
                AppTheme.purple1.withOpacity(0.6)
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: const Color(0xFFE91E63).withOpacity(0.2))),
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
