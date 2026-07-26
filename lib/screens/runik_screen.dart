import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class RunikScreen extends StatefulWidget {
  const RunikScreen({super.key});

  @override
  State<RunikScreen> createState() => _RunikScreenState();
}

class _RunikScreenState extends State<RunikScreen>
    with TickerProviderStateMixin {
  final _random = Random();

  static const _runes = [
    {
      'name': 'Fehu',
      'symbol': 'ᚠ',
      'meaning': 'Bolluk, servet ve başarı. Maddi kazanç kapıda.'
    },
    {
      'name': 'Uruz',
      'symbol': 'ᚢ',
      'meaning': 'Güç, sağlık ve irade. İçindeki güç uyanıyor.'
    },
    {
      'name': 'Thurisaz',
      'symbol': 'ᚦ',
      'meaning': 'Koruma, engel ve dönüşüm. Dikkatli ol.'
    },
    {
      'name': 'Ansuz',
      'symbol': 'ᚨ',
      'meaning': 'İletişim, bilgelik ve ilahi mesaj. Dinle.'
    },
    {
      'name': 'Raidho',
      'symbol': 'ᚱ',
      'meaning': 'Yolculuk, hareket ve değişim. Yola çık.'
    },
    {
      'name': 'Kenaz',
      'symbol': 'ᚲ',
      'meaning': 'Aydınlanma, yaratıcılık ve ateş. Işık sende.'
    },
    {
      'name': 'Gebo',
      'symbol': 'ᚷ',
      'meaning': 'Hediye, ortaklık ve denge. Karşılıklı verim.'
    },
    {
      'name': 'Wunjo',
      'symbol': 'ᚹ',
      'meaning': 'Mutluluk, uyum ve başarı. Neşe geliyor.'
    },
    {
      'name': 'Hagalaz',
      'symbol': 'ᚺ',
      'meaning': 'Değişim, yıkım ve yenilenme. Fırtına geçecek.'
    },
    {
      'name': 'Nauthiz',
      'symbol': 'ᚾ',
      'meaning': 'İhtiyaç, sabır ve dayanıklılık. Güçleniyorsun.'
    },
    {
      'name': 'Isa',
      'symbol': 'ᛁ',
      'meaning': 'Donma, bekleme ve içe dönüş. Sakin ol.'
    },
    {
      'name': 'Jera',
      'symbol': 'ᛃ',
      'meaning': 'Hasat, döngü ve ödül. Emeklerin karşılık bulacak.'
    },
    {
      'name': 'Eihwaz',
      'symbol': 'ᛇ',
      'meaning': 'Güç, esneklik ve dönüşüm. Porsuk ağacı gibi güçlü.'
    },
    {
      'name': 'Perthro',
      'symbol': 'ᛈ',
      'meaning': 'Gizem, kader ve sır. Kaderin açılıyor.'
    },
    {
      'name': 'Algiz',
      'symbol': 'ᛉ',
      'meaning': 'Koruma, savunma ve rehberlik. Korunuyorsun.'
    },
    {
      'name': 'Sowilo',
      'symbol': 'ᛊ',
      'meaning': 'Güneş, zafer ve enerji. Başarı parlıyor.'
    },
    {
      'name': 'Tiwaz',
      'symbol': 'ᛏ',
      'meaning': 'Adalet, cesaret ve fedakarlık. Doğru yoldasın.'
    },
    {
      'name': 'Berkano',
      'symbol': 'ᛒ',
      'meaning': 'Büyüme, doğurganlık ve yenilenme. Yeşeriyorsun.'
    },
    {
      'name': 'Ehwaz',
      'symbol': 'ᛖ',
      'meaning': 'Ortaklık, hareket ve güven. Birlikte güçlüsün.'
    },
    {
      'name': 'Mannaz',
      'symbol': 'ᛗ',
      'meaning': 'İnsanlık, benlik ve topluluk. Kendini tanı.'
    },
    {
      'name': 'Laguz',
      'symbol': 'ᛚ',
      'meaning': 'Su, akış ve sezgi. Duygularına güven.'
    },
    {
      'name': 'Ingwaz',
      'symbol': 'ᛜ',
      'meaning': 'Bereket, tamamlanma ve iç huzur. Döngü kapanıyor.'
    },
    {
      'name': 'Dagaz',
      'symbol': 'ᛞ',
      'meaning': 'Şafak, dönüşüm ve aydınlık. Yeni gün başlıyor.'
    },
    {
      'name': 'Othala',
      'symbol': 'ᛟ',
      'meaning': 'Miras, köken ve aile. Geçmişten güç al.'
    },
  ];

  static const _positions = ['Geçmiş', 'Şimdi', 'Gelecek'];

  List<Map<String, dynamic>> _drawnRunes = [];
  bool _loading = false;
  String? _result;
  late List<AnimationController> _revealControllers;
  late List<Animation<double>> _revealAnimations;
  bool _runesDrawn = false;
  List<bool> _revealed = [false, false, false];

  @override
  void initState() {
    super.initState();
    _revealControllers = List.generate(
        3,
        (i) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 800)));
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

  void _drawRunes() {
    final shuffled = List.of(_runes)..shuffle(_random);
    setState(() {
      _drawnRunes = shuffled.take(3).toList();
      _revealed = [false, false, false];
      _result = null;
      _runesDrawn = true;
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
    final runeDesc = List.generate(
            3,
            (i) =>
                '${_positions[i]}: ${_drawnRunes[i]['name']} (${_drawnRunes[i]['symbol']}) - ${_drawnRunes[i]['meaning']}')
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
                  'Viking runik alfabe falı yorumu yap. Çekilen runlar:\n$runeDesc\n\nHer runun pozisyonuna göre (Geçmiş, Şimdi, Gelecek) Viking geleneğine uygun, mistik ve şiirsel yorum yap. Runların birbirleriyle bağlantısını da anlat. Türkçe, 5-6 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Runlar şu an sessiz... 🌙';
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
      _runesDrawn = false;
      _result = null;
      _revealed = [false, false, false];
      _drawnRunes = [];
    });
    for (final c in _revealControllers) c.reset();
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
          child: const Text('ᚠ Runik Alfabe',
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
              const Text('Viking Kehanet Taşları',
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
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 32),
              if (!_runesDrawn) ...[
                // Torba görseli
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.violet.withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 10)
                    ],
                  ),
                  child: const Center(
                      child: Text('🪨', style: TextStyle(fontSize: 80))),
                ),
                const SizedBox(height: 24),
                const Text('"Runlar seni bekliyor..."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
                const SizedBox(height: 8),
                const Text('24 Viking runundan 3 taş çekeceksin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppTheme.muted)),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _drawRunes,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [AppTheme.gold, AppTheme.violet]),
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.violet.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5))
                        ]),
                    child: const Center(
                        child: Text('🪨 Rune Taşı Çek',
                            style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 1))),
                  ),
                ),
              ] else ...[
                // Çekilen runlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                      3,
                      (i) => AnimatedBuilder(
                            animation: _revealAnimations[i],
                            builder: (context, child) {
                              final scale = _revealAnimations[i].value;
                              return Transform.scale(
                                scale: scale.clamp(0.0, 1.0),
                                child: Container(
                                  width: 90,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2A1A0A),
                                        Color(0xFF4A3020)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppTheme.gold.withOpacity(0.6),
                                        width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                          color: AppTheme.gold.withOpacity(0.2),
                                          blurRadius: 15)
                                    ],
                                  ),
                                  child: _revealed[i] && _drawnRunes.length > i
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                              Text(
                                                _drawnRunes[i]['symbol']
                                                    as String,
                                                style: const TextStyle(
                                                    fontSize: 42,
                                                    color: AppTheme.gold,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                _drawnRunes[i]['name']
                                                    as String,
                                                style: const TextStyle(
                                                    fontFamily: 'Cinzel',
                                                    fontSize: 9,
                                                    color: AppTheme.gold),
                                              ),
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

                if (_revealed[2] && _drawnRunes.length == 3) ...[
                  ...List.generate(
                      3,
                      (i) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A1A0A).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppTheme.gold.withOpacity(0.3)),
                            ),
                            child: Row(children: [
                              Container(
                                width: 50,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A1A0A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppTheme.gold.withOpacity(0.5)),
                                ),
                                child: Center(
                                    child: Text(
                                        _drawnRunes[i]['symbol'] as String,
                                        style: const TextStyle(
                                            fontSize: 28,
                                            color: AppTheme.gold,
                                            fontWeight: FontWeight.bold))),
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
                                    Text(_drawnRunes[i]['name'] as String,
                                        style: const TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 13,
                                            color: AppTheme.white)),
                                    const SizedBox(height: 2),
                                    Text(_drawnRunes[i]['meaning'] as String,
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
                        color: AppTheme.gold, strokeWidth: 2),
                    const SizedBox(height: 12),
                    const Text('Runlar yorumlanıyor... ᚠ✨',
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
                          color: const Color(0xFF2A1A0A).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.gold.withOpacity(0.3))),
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
                            fortuneType: 'Runik Alfabe',
                            fortuneEmoji: '᚛',
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
                            fortuneType: 'Runik Alfabe',
                            fortuneEmoji: '᚛',
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
                                    color: AppTheme.gold.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(25)),
                            child: const Center(
                                child: Text('🔄 Yeni Taş Çek',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.gold,
                                        fontFamily: 'Nunito'))))),
                  ] else ...[
                    GestureDetector(
                      onTap: _getReading,
                      child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [AppTheme.gold, AppTheme.violet]),
                              borderRadius: BorderRadius.circular(27),
                              boxShadow: [
                                BoxShadow(
                                    color: AppTheme.violet.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5))
                              ]),
                          child: const Center(
                              child: Text('🔮 Yorumu Gör',
                                  style: TextStyle(
                                      fontFamily: 'Cinzel',
                                      fontSize: 16,
                                      color: Colors.white,
                                      letterSpacing: 1)))),
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
