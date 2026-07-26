import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class TarotScreen extends StatefulWidget {
  const TarotScreen({super.key});

  @override
  State<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends State<TarotScreen>
    with TickerProviderStateMixin {
  final _random = Random();

  final List<Map<String, String>> _allCards = const [
    {
      'name': 'Ahmak',
      'emoji': '🃏',
      'upright': 'Yeni başlangıçlar, özgürlük, macera',
      'reversed': 'Dikkatsizlik, risk, belirsizlik'
    },
    {
      'name': 'Sihirbaz',
      'emoji': '🎩',
      'upright': 'Güç, beceri, irade',
      'reversed': 'Manipülasyon, zayıflık'
    },
    {
      'name': 'Yüksek Rahibe',
      'emoji': '🌙',
      'upright': 'Sezgi, gizem, iç ses',
      'reversed': 'Gizli gündem, yüzeysellik'
    },
    {
      'name': 'İmparatoriçe',
      'emoji': '👑',
      'upright': 'Bereket, annelik, doğa',
      'reversed': 'Bağımlılık, aşırı koruyuculuk'
    },
    {
      'name': 'İmparator',
      'emoji': '⚔️',
      'upright': 'Otorite, düzen, koruma',
      'reversed': 'Tiranlık, katılık'
    },
    {
      'name': 'Başrahip',
      'emoji': '✝️',
      'upright': 'Gelenek, rehberlik, inanç',
      'reversed': 'Bağnazlık, kısıtlama'
    },
    {
      'name': 'Aşıklar',
      'emoji': '💑',
      'upright': 'Aşk, uyum, seçim',
      'reversed': 'Dengesizlik, kötü seçim'
    },
    {
      'name': 'Savaş Arabası',
      'emoji': '🏆',
      'upright': 'Zafer, irade, başarı',
      'reversed': 'Kontrol kaybı, yenilgi'
    },
    {
      'name': 'Güç',
      'emoji': '🦁',
      'upright': 'Cesaret, sabır, iç güç',
      'reversed': 'Zayıflık, korku'
    },
    {
      'name': 'Ermiş',
      'emoji': '🕯️',
      'upright': 'İçe dönüş, rehberlik, bilgelik',
      'reversed': 'Yalnızlık, izolasyon'
    },
    {
      'name': 'Kader Çarkı',
      'emoji': '☸️',
      'upright': 'Şans, dönüşüm, kader',
      'reversed': 'Talihsizlik, değişime direnç'
    },
    {
      'name': 'Adalet',
      'emoji': '⚖️',
      'upright': 'Denge, hakikat, hukuk',
      'reversed': 'Adaletsizlik, dengesizlik'
    },
    {
      'name': 'Asılan Adam',
      'emoji': '🙃',
      'upright': 'Fedakarlık, bekleme, yeni bakış',
      'reversed': 'Gecikme, direnç'
    },
    {
      'name': 'Ölüm',
      'emoji': '💀',
      'upright': 'Dönüşüm, son ve başlangıç',
      'reversed': 'Değişime direnç, durgunluk'
    },
    {
      'name': 'Denge',
      'emoji': '🌊',
      'upright': 'Denge, sabır, uyum',
      'reversed': 'Aşırılık, dengesizlik'
    },
    {
      'name': 'Şeytan',
      'emoji': '😈',
      'upright': 'Bağlılık, maddecilik, kısıtlama',
      'reversed': 'Özgürlük, bağları kırma'
    },
    {
      'name': 'Kule',
      'emoji': '⚡',
      'upright': 'Ani değişim, yıkım, dönüşüm',
      'reversed': 'Değişime direnç, felaket'
    },
    {
      'name': 'Yıldız',
      'emoji': '⭐',
      'upright': 'Umut, ilham, yenilenme',
      'reversed': 'Umutsuzluk, hayal kırıklığı'
    },
    {
      'name': 'Ay',
      'emoji': '🌕',
      'upright': 'Sezgi, bilinçaltı, korku',
      'reversed': 'Kafa karışıklığı, yanılsama'
    },
    {
      'name': 'Güneş',
      'emoji': '☀️',
      'upright': 'Başarı, neşe, enerji',
      'reversed': 'Aşırı iyimserlik, başarısızlık'
    },
    {
      'name': 'Yargı',
      'emoji': '📯',
      'upright': 'Yenilenme, uyanış, karar',
      'reversed': 'Öz şüphe, kötü karar'
    },
    {
      'name': 'Dünya',
      'emoji': '🌍',
      'upright': 'Tamamlanma, bütünlük, başarı',
      'reversed': 'Eksiklik, gecikme'
    },
  ];

  // Ayrı liste - bool ve String karışmaması için
  List<String> _drawnNames = [];
  List<String> _drawnEmojis = [];
  List<String> _drawnUprights = [];
  List<String> _drawnReversedMeanings = [];
  List<bool> _drawnIsReversed = [];

  bool _loading = false;
  String? _result;
  late List<AnimationController> _flipControllers;
  late List<Animation<double>> _flipAnimations;
  List<bool> _revealed = [false, false, false];
  bool _cardsDrawn = false;

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
    final shuffled = List.of(_allCards)..shuffle(_random);
    final drawn = shuffled.take(3).toList();

    setState(() {
      _drawnNames = drawn.map((c) => c['name']!).toList();
      _drawnEmojis = drawn.map((c) => c['emoji']!).toList();
      _drawnUprights = drawn.map((c) => c['upright']!).toList();
      _drawnReversedMeanings = drawn.map((c) => c['reversed']!).toList();
      _drawnIsReversed = List.generate(3, (_) => _random.nextBool());
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

    final positions = ['Geçmiş', 'Şimdi', 'Gelecek'];
    final cardDesc = List.generate(3, (i) {
      final isRev = _drawnIsReversed[i];
      final meaning = isRev ? _drawnReversedMeanings[i] : _drawnUprights[i];
      return '${positions[i]}: ${_drawnNames[i]} kartı (${isRev ? "Ters" : "Düz"}) - $meaning';
    }).join('\n');

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
                  'Tarot falı yorumu yap. Kartlar:\n$cardDesc\n\nMistik ve şiirsel bir yorum yaz. Geçmiş, şimdi ve gelecek için ayrı ayrı yorumla. Türkçe, 5-6 cümle, emoji kullan, markdown kullanma.',
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
          _result = 'Yıldızlar şu an sessiz... Biraz sonra tekrar dene. 🌙';
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
      _drawnNames = [];
      _drawnEmojis = [];
      _drawnUprights = [];
      _drawnReversedMeanings = [];
      _drawnIsReversed = [];
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
          child: const Text('🃏 Tarot Falı',
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
              const Text('Geçmiş • Şimdi • Gelecek',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 32),
              if (!_cardsDrawn) ...[
                // Ön yüz kartlar
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
                                  height: 140,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: [
                                          AppTheme.purple2,
                                          AppTheme.violet
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppTheme.gold.withOpacity(0.4)),
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
                const SizedBox(height: 32),
                const Text('"Kartlar seni bekliyor..."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
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
                        child: Text('🃏 Kartları Çek',
                            style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 1))),
                  ),
                ),
              ] else ...[
                // Çekilen kartlar - animasyonlu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (i) {
                    return AnimatedBuilder(
                      animation: _flipAnimations[i],
                      builder: (context, child) {
                        final angle = _flipAnimations[i].value * pi;
                        final showFront = angle > pi / 2;
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle > pi / 2 ? pi - angle : angle),
                          child: Container(
                            width: 90,
                            height: 150,
                            decoration: BoxDecoration(
                              gradient: showFront
                                  ? const LinearGradient(
                                      colors: [
                                          Color(0xFF1E0F35),
                                          Color(0xFF3A1060)
                                        ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight)
                                  : const LinearGradient(
                                      colors: [
                                          AppTheme.purple2,
                                          AppTheme.violet
                                        ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppTheme.gold
                                      .withOpacity(showFront ? 0.6 : 0.3)),
                              boxShadow: [
                                BoxShadow(
                                    color: AppTheme.violet.withOpacity(0.4),
                                    blurRadius: 15)
                              ],
                            ),
                            child: showFront && _drawnEmojis.length > i
                                ? Transform.rotate(
                                    angle: _drawnIsReversed[i] ? pi : 0,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(_drawnEmojis[i],
                                            style:
                                                const TextStyle(fontSize: 32)),
                                        const SizedBox(height: 6),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6),
                                          child: Text(_drawnNames[i],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontFamily: 'Cinzel',
                                                  fontSize: 9,
                                                  color: AppTheme.gold)),
                                        ),
                                        if (_drawnIsReversed[i])
                                          const Text('↕ Ters',
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.redAccent,
                                                  fontFamily: 'Nunito')),
                                      ],
                                    ),
                                  )
                                : const Center(
                                    child: Text('✦',
                                        style: TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 28,
                                            color: AppTheme.gold))),
                          ),
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['Geçmiş', 'Şimdi', 'Gelecek']
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

                if (_revealed[2] && _drawnNames.isNotEmpty) ...[
                  // Kart detayları
                  ...List.generate(3, (i) {
                    final isRev = _drawnIsReversed[i];
                    final meaning =
                        isRev ? _drawnReversedMeanings[i] : _drawnUprights[i];
                    final positions = ['Geçmiş', 'Şimdi', 'Gelecek'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: AppTheme.purple1.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppTheme.purple3.withOpacity(0.3))),
                      child: Row(
                        children: [
                          Text(_drawnEmojis[i],
                              style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(positions[i],
                                        style: const TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 10,
                                            color: AppTheme.gold)),
                                    const SizedBox(width: 6),
                                    if (isRev)
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                              color: Colors.redAccent
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          child: const Text('Ters',
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.redAccent,
                                                  fontFamily: 'Nunito'))),
                                  ],
                                ),
                                Text(_drawnNames[i],
                                    style: const TextStyle(
                                        fontFamily: 'Cinzel',
                                        fontSize: 12,
                                        color: AppTheme.white)),
                                const SizedBox(height: 2),
                                Text(meaning,
                                    style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 11,
                                        color: AppTheme.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  if (_loading) ...[
                    const CircularProgressIndicator(
                        color: AppTheme.gold, strokeWidth: 2),
                    const SizedBox(height: 12),
                    const Text('Kartlar yorumlanıyor... 🃏✨',
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
                        final postService = PostService();
                        await postService.createPost(
                            caption:
                                '"${_result!.substring(0, _result!.length > 80 ? 80 : _result!.length)}..."',
                            fortuneType: 'Tarot',
                            fortuneEmoji: '🃏',
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
                        final postService = PostService();
                        await postService.createPost(
                            caption:
                                '"${_result!.substring(0, _result!.length > 80 ? 80 : _result!.length)}..."',
                            fortuneType: 'Tarot',
                            fortuneEmoji: '🃏',
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
                                      fontFamily: 'Nunito')))),
                    ),
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
                                      fontFamily: 'Nunito')))),
                    ),
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
