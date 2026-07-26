import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class LenormandScreen extends StatefulWidget {
  const LenormandScreen({super.key});

  @override
  State<LenormandScreen> createState() => _LenormandScreenState();
}

class _LenormandScreenState extends State<LenormandScreen>
    with TickerProviderStateMixin {
  final _random = Random();

  static const _cards = [
    {
      'name': 'Süvari',
      'emoji': '🐎',
      'meaning': 'Hızlı haberler, değişim, gelişme'
    },
    {
      'name': 'Yonca',
      'emoji': '🍀',
      'meaning': 'Şans, küçük mutluluklar, umut'
    },
    {'name': 'Gemi', 'emoji': '⛵', 'meaning': 'Yolculuk, ticaret, uzak yerler'},
    {'name': 'Ev', 'emoji': '🏠', 'meaning': 'Aile, güvenlik, istikrar'},
    {
      'name': 'Ağaç',
      'emoji': '🌳',
      'meaning': 'Sağlık, büyüme, köklü ilişkiler'
    },
    {
      'name': 'Bulutlar',
      'emoji': '☁️',
      'meaning': 'Belirsizlik, karışıklık, geçici sorunlar'
    },
    {
      'name': 'Yılan',
      'emoji': '🐍',
      'meaning': 'Aldatıcı kadın, karmaşa, akıllı düşman'
    },
    {'name': 'Tabut', 'emoji': '⚰️', 'meaning': 'Son, değişim, dönüşüm'},
    {
      'name': 'Buket',
      'emoji': '💐',
      'meaning': 'Mutluluk, güzellik, hediyeler'
    },
    {'name': 'Orak', 'emoji': '🌾', 'meaning': 'Tehlike, ani değişim, karar'},
    {
      'name': 'Kamçı',
      'emoji': '⚡',
      'meaning': 'Tartışma, çatışma, tekrarlayan sorunlar'
    },
    {'name': 'Kuşlar', 'emoji': '🐦', 'meaning': 'Dedikodu, konuşmalar, çift'},
    {
      'name': 'Çocuk',
      'emoji': '👶',
      'meaning': 'Yenilik, masumiyet, küçük şeyler'
    },
    {'name': 'Tilki', 'emoji': '🦊', 'meaning': 'Kurnazlık, iş, dikkat et'},
    {'name': 'Ayı', 'emoji': '🐻', 'meaning': 'Güç, otorite, kıskançlık'},
    {'name': 'Yıldız', 'emoji': '⭐', 'meaning': 'Umut, rehberlik, başarı'},
    {
      'name': 'Leylek',
      'emoji': '🦢',
      'meaning': 'Değişim, yeni başlangıç, hamilelik'
    },
    {
      'name': 'Köpek',
      'emoji': '🐕',
      'meaning': 'Sadakat, dostluk, güvenilir arkadaş'
    },
    {
      'name': 'Kule',
      'emoji': '🏰',
      'meaning': 'Yalnızlık, otorite, devlet kurumları'
    },
    {
      'name': 'Bahçe',
      'emoji': '🌺',
      'meaning': 'Sosyal hayat, topluluk, kamuoyu'
    },
    {'name': 'Dağ', 'emoji': '⛰️', 'meaning': 'Engel, zorluk, yavaş ilerleme'},
    {
      'name': 'Yollar',
      'emoji': '🛤️',
      'meaning': 'Karar, seçenekler, yol ayrımı'
    },
    {
      'name': 'Fareler',
      'emoji': '🐭',
      'meaning': 'Kayıp, endişe, azalan şeyler'
    },
    {'name': 'Kalp', 'emoji': '❤️', 'meaning': 'Aşk, duygular, ilişki'},
    {'name': 'Yüzük', 'emoji': '💍', 'meaning': 'Bağlılık, sözleşme, evlilik'},
    {'name': 'Kitap', 'emoji': '📚', 'meaning': 'Sırlar, bilgi, gizli şeyler'},
    {'name': 'Mektup', 'emoji': '✉️', 'meaning': 'Haber, belge, iletişim'},
    {
      'name': 'Adam',
      'emoji': '👨',
      'meaning': 'Erkek kişi, partner, önemli adam'
    },
    {
      'name': 'Kadın',
      'emoji': '👩',
      'meaning': 'Kadın kişi, partner, önemli kadın'
    },
    {'name': 'Zambak', 'emoji': '🌸', 'meaning': 'Olgunluk, huzur, uyum'},
    {'name': 'Güneş', 'emoji': '☀️', 'meaning': 'Başarı, mutluluk, enerji'},
    {'name': 'Ay', 'emoji': '🌙', 'meaning': 'Tanınma, duygusallık, sezgi'},
    {'name': 'Anahtar', 'emoji': '🔑', 'meaning': 'Çözüm, başarı, kilit nokta'},
    {'name': 'Balık', 'emoji': '🐟', 'meaning': 'Para, bolluk, bağımsızlık'},
    {'name': 'Çapa', 'emoji': '⚓', 'meaning': 'İstikrar, güvenlik, kalıcılık'},
    {'name': 'Haç', 'emoji': '✝️', 'meaning': 'Kader, yük, kaçınılmaz'},
  ];

  static const _positions = ['Geçmiş', 'Şimdi', 'Gelecek'];
  static const _positionDesc = [
    'Seni buraya getiren',
    'Şu anki durumun',
    'Yakında yaşanacak'
  ];

  List<Map<String, dynamic>> _drawnCards = [];
  bool _loading = false;
  String? _result;
  late List<AnimationController> _flipControllers;
  late List<Animation<double>> _flipAnimations;
  bool _cardsDrawn = false;
  List<bool> _revealed = [false, false, false];

  @override
  void initState() {
    super.initState();
    _flipControllers = List.generate(
        3,
        (i) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 600)));
    _flipAnimations = _flipControllers
        .map((c) => Tween<double>(begin: 0, end: 1)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _flipControllers) c.dispose();
    super.dispose();
  }

  void _drawCards() {
    final shuffled = List.of(_cards)..shuffle(_random);
    setState(() {
      _drawnCards = shuffled.take(3).toList();
      _revealed = [false, false, false];
      _result = null;
      _cardsDrawn = true;
    });
    for (int i = 0; i < 3; i++) {
      _flipControllers[i].reset();
      Future.delayed(Duration(milliseconds: 400 * i), () {
        if (mounted) {
          _flipControllers[i].forward();
          setState(() => _revealed[i] = true);
        }
      });
    }
  }

  Future<void> _getReading() async {
    setState(() => _loading = true);
    final cardDesc = List.generate(
            3,
            (i) =>
                '${_positions[i]} (${_positionDesc[i]}): ${_drawnCards[i]['name']} - ${_drawnCards[i]['meaning']}')
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
                  'Fransız Lenormand kart falı yorumu yap. Kartlar:\n$cardDesc\n\nHer kartı pozisyonuna göre mistik ve şiirsel yorumla. Kartlar arasındaki bağlantıyı da anlat. Türkçe, 5-6 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Kartlar şu an sessiz... 🌙';
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
      _cardsDrawn = false;
      _result = null;
      _revealed = [false, false, false];
      _drawnCards = [];
    });
    for (final c in _flipControllers) c.reset();
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
          child: const Text('🌺 Lenormand',
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
              const Text('Fransız Kehanet Kartları',
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
              if (!_cardsDrawn) ...[
                SizedBox(
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: List.generate(
                        3,
                        (i) => Positioned(
                              left: MediaQuery.of(context).size.width / 2 -
                                  100 +
                                  i * 30.0,
                              child: Transform.rotate(
                                angle: (i - 1) * 0.15,
                                child: Container(
                                  width: 90,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2D1654),
                                          Color(0xFF1A4060)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppTheme.gold.withOpacity(0.5)),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              AppTheme.violet.withOpacity(0.3),
                                          blurRadius: 15)
                                    ],
                                  ),
                                  child: const Center(
                                      child: Text('✦',
                                          style: TextStyle(
                                              fontFamily: 'Cinzel',
                                              fontSize: 28,
                                              color: AppTheme.gold))),
                                ),
                              ),
                            )),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('"Lenormand kartları seni bekliyor..."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
                const SizedBox(height: 8),
                const Text(
                    'Madame Lenormand\'ın 36 kehanet kartından 3 kart çekeceksin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppTheme.muted)),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _drawCards,
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
                        child: Text('🌺 Kartları Çek',
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
                            animation: _flipAnimations[i],
                            builder: (context, child) {
                              final angle = _flipAnimations[i].value * pi;
                              final showFront = angle > pi / 2;
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(
                                      angle > pi / 2 ? pi - angle : angle),
                                child: Container(
                                  width: 90,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    gradient: showFront
                                        ? const LinearGradient(
                                            colors: [
                                                Color(0xFF1A4060),
                                                Color(0xFF2D1654)
                                              ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight)
                                        : const LinearGradient(
                                            colors: [
                                                Color(0xFF2D1654),
                                                Color(0xFF1A4060)
                                              ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppTheme.gold.withOpacity(
                                            showFront ? 0.7 : 0.4)),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              AppTheme.violet.withOpacity(0.4),
                                          blurRadius: 15)
                                    ],
                                  ),
                                  child: showFront && _drawnCards.length > i
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                              Text(
                                                  _drawnCards[i]['emoji']
                                                      as String,
                                                  style: const TextStyle(
                                                      fontSize: 36)),
                                              const SizedBox(height: 8),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6),
                                                child: Text(
                                                    _drawnCards[i]['name']
                                                        as String,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontFamily: 'Cinzel',
                                                        fontSize: 10,
                                                        color: AppTheme.gold)),
                                              ),
                                            ])
                                      : const Center(
                                          child: Text('✦',
                                              style: TextStyle(
                                                  fontFamily: 'Cinzel',
                                                  fontSize: 28,
                                                  color: AppTheme.gold))),
                                ),
                              );
                            },
                          )),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                      3,
                      (i) => SizedBox(
                            width: 90,
                            child: Column(children: [
                              Text(_positions[i],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Cinzel',
                                      fontSize: 10,
                                      color: AppTheme.gold)),
                              Text(_positionDesc[i],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 9,
                                      color: AppTheme.muted)),
                            ]),
                          )),
                ),
                const SizedBox(height: 24),
                if (_revealed[2] && _drawnCards.length == 3) ...[
                  ...List.generate(
                      3,
                      (i) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: AppTheme.purple1.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppTheme.purple3.withOpacity(0.3))),
                            child: Row(children: [
                              Text(_drawnCards[i]['emoji'] as String,
                                  style: const TextStyle(fontSize: 32)),
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
                                    Text(_drawnCards[i]['name'] as String,
                                        style: const TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 13,
                                            color: AppTheme.white)),
                                    const SizedBox(height: 2),
                                    Text(_drawnCards[i]['meaning'] as String,
                                        style: const TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 11,
                                            color: AppTheme.muted)),
                                  ])),
                            ]),
                          )),
                  const SizedBox(height: 16),
                  if (_loading) ...[
                    const CircularProgressIndicator(
                        color: AppTheme.gold, strokeWidth: 2),
                    const SizedBox(height: 12),
                    const Text('Lenormand yorumlanıyor... 🌺✨',
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
                          color: AppTheme.purple1.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.purple3.withOpacity(0.4))),
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
                            fortuneType: 'Lenormand',
                            fortuneEmoji: '🌺',
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
                            fortuneType: 'Lenormand',
                            fortuneEmoji: '🌺',
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
                                child: Text('🔄 Yeni Kartlar Çek',
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
