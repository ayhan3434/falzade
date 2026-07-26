import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class MelekScreen extends StatefulWidget {
  const MelekScreen({super.key});

  @override
  State<MelekScreen> createState() => _MelekScreenState();
}

class _MelekScreenState extends State<MelekScreen>
    with TickerProviderStateMixin {
  final _random = Random();

  static const _cards = [
    {
      'name': 'Mikail',
      'emoji': '⚔️',
      'meaning': 'Koruma, cesaret ve güç. Seni koruyan güçlü bir enerji var.',
      'color': 0xFF1A3A6B
    },
    {
      'name': 'Cebrail',
      'emoji': '📯',
      'meaning': 'Müjde, ilham ve yeni başlangıçlar. Önemli bir haber yolda.',
      'color': 0xFF6B1A3A
    },
    {
      'name': 'Azrail',
      'emoji': '🌙',
      'meaning':
          'Dönüşüm, bırakma ve yenilenme. Bir şeyin sonu yeni bir başlangıç.',
      'color': 0xFF1A1A6B
    },
    {
      'name': 'İsrafil',
      'emoji': '🎺',
      'meaning': 'Uyanış, farkındalık ve ruhsal gelişim. İçindeki sesi dinle.',
      'color': 0xFF3A6B1A
    },
    {
      'name': 'Sariel',
      'emoji': '🌟',
      'meaning': 'Rehberlik, yönlendirme ve aydınlanma. Doğru yoldasın.',
      'color': 0xFF6B5A1A
    },
    {
      'name': 'Raphael',
      'emoji': '💚',
      'meaning': 'Şifa, iyileşme ve denge. Bedenin ve ruhun iyileşiyor.',
      'color': 0xFF1A6B3A
    },
    {
      'name': 'Uriel',
      'emoji': '🔥',
      'meaning': 'Bilgelik, aydınlanma ve içsel güç. Cevap içinde saklı.',
      'color': 0xFF6B3A1A
    },
    {
      'name': 'Chamuel',
      'emoji': '❤️',
      'meaning': 'Sevgi, ilişkiler ve affetme. Kalbin açılmaya hazır.',
      'color': 0xFF6B1A1A
    },
    {
      'name': 'Jophiel',
      'emoji': '🌸',
      'meaning':
          'Güzellik, yaratıcılık ve pozitif düşünce. Etrafındaki güzelliği gör.',
      'color': 0xFF6B1A5A
    },
    {
      'name': 'Zadkiel',
      'emoji': '💜',
      'meaning': 'Şefkat, merhamet ve özgürlük. Geçmişi bırakma zamanı.',
      'color': 0xFF3A1A6B
    },
    {
      'name': 'Haniel',
      'emoji': '🌙',
      'meaning': 'Sezgi, zariflik ve ay enerjisi. Sezgilerine güven.',
      'color': 0xFF1A4A6B
    },
    {
      'name': 'Metatron',
      'emoji': '✡️',
      'meaning':
          'Kutsal geometri, evrensel düzen ve ruhsal evrim. Büyük bir dönüşüm yakın.',
      'color': 0xFF5A5A1A
    },
    {
      'name': 'Sandalphon',
      'emoji': '🎵',
      'meaning': 'Dualar, müzik ve yeryüzü bağlantısı. Duaların duyuluyor.',
      'color': 0xFF1A6B5A
    },
    {
      'name': 'Ariel',
      'emoji': '🦁',
      'meaning':
          'Doğa, cesaret ve hayvanların koruyucusu. Güçlü bir enerji yanında.',
      'color': 0xFF4A6B1A
    },
    {
      'name': 'Azael',
      'emoji': '⚡',
      'meaning': 'Değişim, dinamizm ve güç. Harekete geçme zamanı.',
      'color': 0xFF6B4A1A
    },
    {
      'name': 'Cassiel',
      'emoji': '⏳',
      'meaning':
          'Sabır, zaman ve karma. Doğru an geldiğinde her şey yerli yerine oturacak.',
      'color': 0xFF2A2A6B
    },
    {
      'name': 'Muriel',
      'emoji': '🌊',
      'meaning': 'Duygular, empati ve derin sezgi. Duygularını kabul et.',
      'color': 0xFF1A5A6B
    },
    {
      'name': 'Barachiel',
      'emoji': '🍀',
      'meaning': 'Bereket, şans ve bolluk. Şans kapının önünde.',
      'color': 0xFF1A6B2A
    },
    {
      'name': 'Seraphiel',
      'emoji': '✨',
      'meaning': 'İlahi sevgi, saflık ve yüksek titreşim. Ruhun yükseliyor.',
      'color': 0xFF6B6B1A
    },
    {
      'name': 'Koruyucu Meleğin',
      'emoji': '👼',
      'meaning': 'Kişisel koruma, rehberlik ve şefkat. Meleğin seninle her an.',
      'color': 0xFF4A1A6B
    },
  ];

  static const _positions = ['Geçmiş', 'Şimdi', 'Gelecek'];

  List<Map<String, dynamic>> _drawnCards = [];
  bool _loading = false;
  String? _result;
  late List<AnimationController> _flipControllers;
  late List<Animation<double>> _flipAnimations;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _cardsDrawn = false;
  List<bool> _revealed = [false, false, false];

  @override
  void initState() {
    super.initState();
    _flipControllers = List.generate(
        3,
        (i) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 700)));
    _flipAnimations = _flipControllers
        .map((c) => Tween<double>(begin: 0, end: 1)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _glowAnimation =
        Tween<double>(begin: 0.3, end: 1.0).animate(_glowController);
  }

  @override
  void dispose() {
    for (final c in _flipControllers) c.dispose();
    _glowController.dispose();
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
      Future.delayed(Duration(milliseconds: 500 * i), () {
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
                '${_positions[i]}: ${_drawnCards[i]['name']} Meleği - ${_drawnCards[i]['meaning']}')
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
                  'Melek falı yorumu yap. Çekilen melek kartları:\n$cardDesc\n\nHer meleğin mesajını pozisyonuna göre (Geçmiş, Şimdi, Gelecek) mistik, umut dolu ve şiirsel şekilde yorumla. Meleklerin birlikte verdiği mesajı da anlat. Türkçe, 5-6 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Melekler şu an sessiz... 🌙';
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
          child: const Text('👼 Melek Falı',
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
              const Text('Meleklerin Mesajı',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 32),
              if (!_cardsDrawn) ...[
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) => Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.white
                                .withOpacity(_glowAnimation.value * 0.3),
                            blurRadius: 40,
                            spreadRadius: 10),
                        BoxShadow(
                            color: AppTheme.gold
                                .withOpacity(_glowAnimation.value * 0.4),
                            blurRadius: 60,
                            spreadRadius: 20),
                      ],
                    ),
                    child: const Center(
                        child: Text('👼', style: TextStyle(fontSize: 80))),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('"Melekler senin için burada..."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
                const SizedBox(height: 8),
                const Text('20 melek kartından 3 melek sana mesaj gönderecek',
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
                      gradient: const LinearGradient(colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFFFFFF),
                        Color(0xFFFFD700)
                      ]),
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5))
                      ],
                    ),
                    child: const Center(
                        child: Text('👼 Melek Kartı Çek',
                            style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 16,
                                color: Color(0xFF1A0D2A),
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
                              final cardColor = _drawnCards.length > i
                                  ? Color(_drawnCards[i]['color'] as int)
                                  : AppTheme.purple2;
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(
                                      angle > pi / 2 ? pi - angle : angle),
                                child: Container(
                                  width: 90,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    gradient: showFront
                                        ? LinearGradient(
                                            colors: [
                                                cardColor,
                                                cardColor.withOpacity(0.6)
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
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: Colors.white
                                            .withOpacity(showFront ? 0.5 : 0.2),
                                        width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.white.withOpacity(
                                              showFront ? 0.2 : 0.1),
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
                                                    '${_drawnCards[i]['name']}\nMeleği',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontFamily: 'Cinzel',
                                                        fontSize: 9,
                                                        color: Colors.white,
                                                        height: 1.3)),
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
                if (_revealed[2] && _drawnCards.length == 3) ...[
                  ...List.generate(
                      3,
                      (i) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Color(_drawnCards[i]['color'] as int)
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
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
                                    Text('${_drawnCards[i]['name']} Meleği',
                                        style: const TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 13,
                                            color: Colors.white)),
                                    const SizedBox(height: 2),
                                    Text(_drawnCards[i]['meaning'] as String,
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
                    const Text('Melekler mesaj gönderiyor... 👼✨',
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
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.2))),
                      child: Text(_result!,
                          style: const TextStyle(
                              fontFamily: 'Cormorant Garamond',
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
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
                            fortuneType: 'Melek Falı',
                            fortuneEmoji: '👼',
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
                            fortuneType: 'Melek Falı',
                            fortuneEmoji: '👼',
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
                          gradient: const LinearGradient(colors: [
                            Color(0xFFFFD700),
                            Color(0xFFFFFFFF),
                            Color(0xFFFFD700)
                          ]),
                          borderRadius: BorderRadius.circular(27),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5))
                          ],
                        ),
                        child: const Center(
                            child: Text('👼 Meleklerin Mesajını Al',
                                style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 15,
                                    color: Color(0xFF1A0D2A),
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
