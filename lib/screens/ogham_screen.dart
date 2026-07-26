import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class OghamScreen extends StatefulWidget {
  const OghamScreen({super.key});

  @override
  State<OghamScreen> createState() => _OghamScreenState();
}

class _OghamScreenState extends State<OghamScreen>
    with TickerProviderStateMixin {
  final _random = Random();

  static const _ogham = [
    {
      'name': 'Beith',
      'symbol': 'ᚁ',
      'tree': 'Huş Ağacı',
      'meaning':
          'Yeni başlangıçlar, arınma ve tazelenme. Beyaz sayfan açılıyor.'
    },
    {
      'name': 'Luis',
      'symbol': 'ᚂ',
      'tree': 'Kızılcık',
      'meaning': 'Koruma, sezgi ve kehanet. İçgüdülerine güven.'
    },
    {
      'name': 'Fearn',
      'symbol': 'ᚃ',
      'tree': 'Kızılağaç',
      'meaning': 'Kalkan, cesaret ve dayanıklılık. Korunuyorsun.'
    },
    {
      'name': 'Sail',
      'symbol': 'ᚄ',
      'tree': 'Söğüt',
      'meaning': 'Ay enerjisi, sezgi ve derin duygular. Akarsu gibi ol.'
    },
    {
      'name': 'Nion',
      'symbol': 'ᚅ',
      'tree': 'Dişbudak',
      'meaning': 'Bağlantı, köprü ve dönüşüm. Dünyalar arası geçiş.'
    },
    {
      'name': 'Huath',
      'symbol': 'ᚆ',
      'tree': 'Alıç',
      'meaning': 'Temizlenme, bekleme ve hazırlık. Sabır zamanı.'
    },
    {
      'name': 'Duir',
      'symbol': 'ᚇ',
      'tree': 'Meşe',
      'meaning': 'Güç, koruma ve bilgelik. Meşe gibi köklü ol.'
    },
    {
      'name': 'Tinne',
      'symbol': 'ᚈ',
      'tree': 'Çobanpüskülü',
      'meaning': 'Denge, adalet ve meydan okuma. Savaşmaya hazır ol.'
    },
    {
      'name': 'Coll',
      'symbol': 'ᚉ',
      'tree': 'Fındık',
      'meaning': 'Bilgelik, ilham ve yaratıcılık. Zihnin açılıyor.'
    },
    {
      'name': 'Quert',
      'symbol': 'ᚊ',
      'tree': 'Elma',
      'meaning': 'Güzellik, aşk ve öteki dünya. Cennet meyveleri.'
    },
    {
      'name': 'Muin',
      'symbol': 'ᚋ',
      'tree': 'Asma',
      'meaning': 'İç gerçeklik, dürüstlük ve kehanet. Gerçeği gör.'
    },
    {
      'name': 'Gort',
      'symbol': 'ᚌ',
      'tree': 'Sarmaşık',
      'meaning': 'Kararlılık, büyüme ve bağlılık. Sardıkça güçleniyorsun.'
    },
    {
      'name': 'Ngetal',
      'symbol': 'ᚍ',
      'tree': 'Kamış',
      'meaning': 'Şifa, müzik ve uyum. İyileşme zamanı.'
    },
    {
      'name': 'Straif',
      'symbol': 'ᚎ',
      'tree': 'Kara Erik',
      'meaning': 'Kader, zorunluluk ve dönüşüm. Kaçınılmaz değişim.'
    },
    {
      'name': 'Ruis',
      'symbol': 'ᚏ',
      'tree': 'Mürver',
      'meaning': 'Yeniden doğuş, dönüşüm ve büyü. Ölümden hayat.'
    },
    {
      'name': 'Ailm',
      'symbol': 'ᚐ',
      'tree': 'Çam',
      'meaning': 'Netlik, perspektif ve uzak görüş. Yüksekten bak.'
    },
    {
      'name': 'Onn',
      'symbol': 'ᚑ',
      'tree': 'Katır Tırnağı',
      'meaning': 'Derleme, hazırlık ve pratiklik. Enerjini topla.'
    },
    {
      'name': 'Ur',
      'symbol': 'ᚒ',
      'tree': 'Funda',
      'meaning': 'Tutku, aşk ve romantizm. Kalbin konuşuyor.'
    },
    {
      'name': 'Edad',
      'symbol': 'ᚓ',
      'tree': 'Kavak',
      'meaning': 'Denge, karşıtlık ve seçim. İki yol önünde.'
    },
    {
      'name': 'Idad',
      'symbol': 'ᚔ',
      'tree': 'Porsuk',
      'meaning': 'Ölümsüzlük, uzun ömür ve dönüşüm. Zamansız enerji.'
    },
  ];

  static const _positions = ['Geçmiş', 'Şimdi', 'Gelecek'];

  List<Map<String, dynamic>> _drawnOgham = [];
  bool _loading = false;
  String? _result;
  late List<AnimationController> _revealControllers;
  late List<Animation<double>> _revealAnimations;
  bool _oghamDrawn = false;
  List<bool> _revealed = [false, false, false];

  @override
  void initState() {
    super.initState();
    _revealControllers = List.generate(
        3,
        (i) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 900)));
    _revealAnimations = _revealControllers
        .map((c) => Tween<double>(begin: 0, end: 1)
            .animate(CurvedAnimation(parent: c, curve: Curves.elasticOut)))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _revealControllers) c.dispose();
    super.dispose();
  }

  void _drawOgham() {
    final shuffled = List.of(_ogham)..shuffle(_random);
    setState(() {
      _drawnOgham = shuffled.take(3).toList();
      _revealed = [false, false, false];
      _result = null;
      _oghamDrawn = true;
    });
    for (int i = 0; i < 3; i++) {
      _revealControllers[i].reset();
      Future.delayed(Duration(milliseconds: 500 * i), () {
        if (mounted) {
          _revealControllers[i].forward();
          setState(() => _revealed[i] = true);
        }
      });
    }
  }

  Future<void> _getReading() async {
    setState(() => _loading = true);
    final oghamDesc = List.generate(
            3,
            (i) =>
                '${_positions[i]}: ${_drawnOgham[i]['name']} (${_drawnOgham[i]['tree']}) - ${_drawnOgham[i]['meaning']}')
        .join('\n');

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
          'max_tokens': 500,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Kelt Ogham ağaç alfabesi falı yorumu yap. Çekilen semboller:\n$oghamDesc\n\nHer sembolün ağaç enerjisini ve pozisyonunu (Geçmiş, Şimdi, Gelecek) Kelt geleneğine uygun, doğa temalı, mistik ve şiirsel şekilde yorumla. Ağaçların birbirleriyle oluşturduğu mesajı da anlat. Türkçe, 5-6 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Ağaçlar şu an sessiz... 🌿';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Orman şu an konuşmuyor... ✨';
        _loading = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _oghamDrawn = false;
      _result = null;
      _revealed = [false, false, false];
      _drawnOgham = [];
    });
    for (final c in _revealControllers) c.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppTheme.gold, size: 20),
            onPressed: () => Navigator.pop(context)),
        title: ShaderMask(
          shaderCallback: (bounds) => AppTheme.goldToLilac.createShader(bounds),
          child: const Text('🌿 Ogham',
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
              const Text('Kelt Ağaç Kehaneti',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 8),
              const Text('Geçmiş • Şimdi • Gelecek',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 13,
                      color: AppTheme.muted)),
              const SizedBox(height: 32),
              if (!_oghamDrawn) ...[
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                    BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 10)
                  ]),
                  child: const Center(
                      child: Text('🌳', style: TextStyle(fontSize: 80))),
                ),
                const SizedBox(height: 24),
                const Text('"Ormanın sesi seni çağırıyor..."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
                const SizedBox(height: 8),
                const Text('20 Kelt ağaç sembolünden 3 tanesini çekeceksin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppTheme.muted)),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _drawOgham,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF1A4A1A), Color(0xFF2A6A2A)]),
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5))
                      ],
                    ),
                    child: const Center(
                        child: Text('🌿 Ogham Çek',
                            style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 1))),
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                      3,
                      (i) => AnimatedBuilder(
                            animation: _revealAnimations[i],
                            builder: (context, child) {
                              final scale =
                                  _revealAnimations[i].value.clamp(0.0, 1.0);
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 90,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF0A2A0A),
                                        Color(0xFF1A4A1A)
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.green.withOpacity(0.5),
                                        width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.green.withOpacity(0.2),
                                          blurRadius: 15)
                                    ],
                                  ),
                                  child: _revealed[i] && _drawnOgham.length > i
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                              Text(
                                                _drawnOgham[i]['symbol']
                                                    as String,
                                                style: const TextStyle(
                                                    fontSize: 40,
                                                    color: Color(0xFF7CFC00),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                  _drawnOgham[i]['name']
                                                      as String,
                                                  style: const TextStyle(
                                                      fontFamily: 'Cinzel',
                                                      fontSize: 9,
                                                      color: Colors.white)),
                                              Text(
                                                  _drawnOgham[i]['tree']
                                                      as String,
                                                  style: TextStyle(
                                                      fontFamily: 'Nunito',
                                                      fontSize: 8,
                                                      color: Colors
                                                          .green.shade300)),
                                            ])
                                      : const Center(
                                          child: Text('?',
                                              style: TextStyle(
                                                  fontFamily: 'Cinzel',
                                                  fontSize: 36,
                                                  color: AppTheme.muted))),
                                ),
                              );
                            },
                          )),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _positions
                      .map((p) => SizedBox(
                          width: 90,
                          child: Text(p,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 10,
                                  color: AppTheme.muted))))
                      .toList(),
                ),
                const SizedBox(height: 24),
                if (_revealed[2] && _drawnOgham.length == 3) ...[
                  ...List.generate(
                      3,
                      (i) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A2A0A).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Row(children: [
                              Container(
                                width: 50,
                                height: 65,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF0A2A0A),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.green.withOpacity(0.5))),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(_drawnOgham[i]['symbol'] as String,
                                          style: const TextStyle(
                                              fontSize: 26,
                                              color: Color(0xFF7CFC00),
                                              fontWeight: FontWeight.bold)),
                                      Text(_drawnOgham[i]['name'] as String,
                                          style: const TextStyle(
                                              fontFamily: 'Cinzel',
                                              fontSize: 7,
                                              color: Colors.white)),
                                    ]),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(_positions[i],
                                        style: const TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 10,
                                            color: AppTheme.gold)),
                                    Text(
                                        '${_drawnOgham[i]['name']} - ${_drawnOgham[i]['tree']}',
                                        style: const TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 12,
                                            color: Colors.white)),
                                    const SizedBox(height: 2),
                                    Text(_drawnOgham[i]['meaning'] as String,
                                        style: const TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 11,
                                            color: AppTheme.muted,
                                            height: 1.4)),
                                  ])),
                            ]),
                          )),
                  const SizedBox(height: 16),
                  if (_loading) ...[
                    const CircularProgressIndicator(
                        color: Colors.green, strokeWidth: 2),
                    const SizedBox(height: 12),
                    const Text('Ağaçlar konuşuyor... 🌿✨',
                        style: TextStyle(
                            fontFamily: 'Cormorant Garamond',
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.muted)),
                  ] else if (_result != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: const Color(0xFF0A2A0A).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.green.withOpacity(0.3))),
                      child: Text(_result!,
                          style: const TextStyle(
                              fontFamily: 'Cormorant Garamond',
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.muted,
                              height: 1.8)),
                    ),
                    const SizedBox(height: 20),
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
                            fortuneType: 'Ogham',
                            fortuneEmoji: '🌿',
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
                            fortuneType: 'Ogham',
                            fortuneEmoji: '🌿',
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
                        onTap: _reset,
                        child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.green.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(25)),
                            child: const Center(
                                child: Text('🔄 Yeni Sembol Çek',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.green,
                                        fontFamily: 'Nunito'))))),
                  ] else ...[
                    GestureDetector(
                      onTap: _getReading,
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFF1A4A1A), Color(0xFF2A6A2A)]),
                            borderRadius: BorderRadius.circular(27),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5))
                            ]),
                        child: const Center(
                            child: Text('🔮 Yorumu Gör',
                                style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 16,
                                    color: Colors.white,
                                    letterSpacing: 1))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                        onTap: _reset,
                        child: Container(
                            width: double.infinity,
                            height: 46,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppTheme.muted.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(23)),
                            child: const Center(
                                child: Text('🔄 Tekrar Çek',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.muted,
                                        fontFamily: 'Nunito'))))),
                  ],
                ],
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
