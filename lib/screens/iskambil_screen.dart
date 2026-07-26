import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class IskambilScreen extends StatefulWidget {
  const IskambilScreen({super.key});

  @override
  State<IskambilScreen> createState() => _IskambilScreenState();
}

class _IskambilScreenState extends State<IskambilScreen>
    with TickerProviderStateMixin {
  final _random = Random();
  final _intentController = TextEditingController();

  // Adımlar: 0=niyet, 1=karıştır, 2=kes, 3=kartlar açılıyor, 4=yorum
  int _step = 0;
  int _shuffleCount = 0;
  int _cutCount = 0;
  bool _loading = false;
  String? _result;
  String _intent = '';

  List<Map<String, dynamic>> _deck = [];
  List<Map<String, dynamic>> _drawnCards = [];
  List<bool> _revealed = [];

  late List<AnimationController> _cardControllers;
  late AnimationController _shuffleController;
  late Animation<double> _shuffleAnimation;

  static const _suits = [
    {
      'symbol': '♥',
      'name': 'Kupa',
      'meaning': 'Aşk, duygular ve ilişkiler',
      'color': 0xFFD50000,
      'isRed': true
    },
    {
      'symbol': '♦',
      'name': 'Karo',
      'meaning': 'Para, iş ve maddi konular',
      'color': 0xFFD50000,
      'isRed': true
    },
    {
      'symbol': '♠',
      'name': 'Maça',
      'meaning': 'Zorluklar, düşünceler ve kaderler',
      'color': 0xFF1A1A1A,
      'isRed': false
    },
    {
      'symbol': '♣',
      'name': 'Sinek',
      'meaning': 'Şans, haberler ve girişimler',
      'color': 0xFF1A1A1A,
      'isRed': false
    },
  ];

  static const _values = [
    'A',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    'J',
    'Q',
    'K'
  ];

  static const _valueMeanings = {
    'A': 'Yeni başlangıç ve büyük güç',
    '2': 'Denge ve ortaklık',
    '3': 'Büyüme ve yaratıcılık',
    '4': 'İstikrar ve temel',
    '5': 'Değişim ve meydan okuma',
    '6': 'Uyum ve sorumluluk',
    '7': 'Gizem ve sezgi',
    '8': 'Güç ve başarı',
    '9': 'Tamamlanma ve bilgelik',
    '10': 'Mükemmellik ve yeni dönem',
    'J': 'Genç ve dinamik enerji',
    'Q': 'Olgun kadın enerjisi',
    'K': 'Otorite ve güç',
  };

  static const _positions = [
    'Geçmiş',
    'Şimdi',
    'Gelecek',
    'Ev & Aile',
    'Aşk & İlişki',
    'İş & Para',
    'Sürpriz'
  ];

  static const _positionDescs = [
    'Seni buraya getiren',
    'Şu anki durum',
    'Yakında gelecek',
    'Ev ve aile hayatın',
    'Aşk ve ilişkilerin',
    'İş ve maddi durum',
    'Beklenmedik gelişme',
  ];

  @override
  void initState() {
    super.initState();
    _buildDeck();
    _shuffleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shuffleAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
        CurvedAnimation(
            parent: _shuffleController, curve: Curves.elasticInOut));
    _cardControllers = List.generate(
        7,
        (i) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 600)));
  }

  void _buildDeck() {
    _deck = [];
    for (final suit in _suits) {
      for (final value in _values) {
        _deck.add({'suit': suit, 'value': value});
      }
    }
    _deck.shuffle(_random);
  }

  @override
  void dispose() {
    _shuffleController.dispose();
    for (final c in _cardControllers) c.dispose();
    _intentController.dispose();
    super.dispose();
  }

  Future<void> _shuffle() async {
    _shuffleController.reset();
    _shuffleController.repeat(reverse: true);
    await Future.delayed(const Duration(milliseconds: 600));
    _shuffleController.stop();
    _deck.shuffle(_random);
    setState(() => _shuffleCount++);
    if (_shuffleCount >= 3) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) setState(() => _step = 2);
    }
  }

  void _cut() {
    final cutPoint = _random.nextInt(_deck.length - 10) + 5;
    final top = _deck.sublist(0, cutPoint);
    final bottom = _deck.sublist(cutPoint);
    _deck = [...bottom, ...top];
    setState(() => _cutCount++);
    if (_cutCount >= 3) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _step = 3);
        _dealCards();
      });
    }
  }

  void _dealCards() {
    _drawnCards = _deck.take(7).toList();
    _revealed = List.filled(7, false);
    for (int i = 0; i < 7; i++) {
      _cardControllers[i].reset();
      Future.delayed(Duration(milliseconds: 350 * i), () {
        if (mounted) {
          _cardControllers[i].forward();
          setState(() => _revealed[i] = true);
        }
      });
    }
    Future.delayed(const Duration(milliseconds: 350 * 7), () {
      if (mounted) setState(() => _step = 4);
    });
  }

  Future<void> _getReading() async {
    setState(() => _loading = true);
    final cardDesc = List.generate(7, (i) {
      final card = _drawnCards[i];
      final suit = card['suit'] as Map<String, dynamic>;
      final value = card['value'] as String;
      return '${_positions[i]} (${_positionDescs[i]}): ${suit['symbol']} ${suit['name']} $value - ${_valueMeanings[value]}, ${suit['meaning']}';
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
          'max_tokens': 600,
          'messages': [
            {
              'role': 'user',
              'content':
                  'İskambil falı yorumu yap. Niyet: "$_intent"\nAçılan 7 kart:\n$cardDesc\n\nHer kartı pozisyonuna ve rengine (Kupa=aşk, Karo=para, Maça=zorluk, Sinek=şans) göre yorumla. Genel mesajı da anlat. Türkçe, 6-7 cümle, mistik ve şiirsel ol, emoji kullan, markdown kullanma.'
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
    _buildDeck();
    setState(() {
      _step = 0;
      _shuffleCount = 0;
      _cutCount = 0;
      _result = null;
      _intent = '';
      _drawnCards = [];
      _revealed = [];
    });
    _intentController.clear();
    for (final c in _cardControllers) c.reset();
  }

  Widget _buildCardFace(Map<String, dynamic> card) {
    final suit = card['suit'] as Map<String, dynamic>;
    final value = card['value'] as String;
    final isRed = suit['isRed'] as bool;
    final color = isRed ? Colors.red : Colors.black;

    return Container(
      width: 52,
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: AppTheme.violet.withOpacity(0.3), blurRadius: 8)
        ],
      ),
      child: Stack(children: [
        Positioned(
            top: 3,
            left: 4,
            child: Column(children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold, color: color)),
              Text(suit['symbol'] as String,
                  style: TextStyle(fontSize: 8, color: color)),
            ])),
        Center(
            child: Text(suit['symbol'] as String,
                style: TextStyle(fontSize: 22, color: color))),
        Positioned(
            bottom: 3,
            right: 4,
            child: Column(children: [
              Text(suit['symbol'] as String,
                  style: TextStyle(fontSize: 8, color: color)),
              Text(value,
                  style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold, color: color)),
            ])),
      ]),
    );
  }

  Widget _buildCardBack({double width = 52, double height = 78}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppTheme.purple2, AppTheme.violet],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: AppTheme.violet.withOpacity(0.3), blurRadius: 8)
        ],
      ),
      child: const Center(
          child: Text('✦',
              style: TextStyle(
                  fontFamily: 'Cinzel', fontSize: 18, color: AppTheme.gold))),
    );
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
          child: const Text('🎴 İskambil Falı',
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
              // Adım göstergesi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    4,
                    (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _step.clamp(0, 3) ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i <= _step.clamp(0, 3)
                                ? AppTheme.gold
                                : AppTheme.muted.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
              ),
              const SizedBox(height: 24),

              // ADIM 0: Niyet
              if (_step == 0) ...[
                const Text('🎴', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.goldToLilac.createShader(bounds),
                  child: const Text('İskambil Falı',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 22,
                          color: Colors.white,
                          letterSpacing: 1)),
                ),
                const SizedBox(height: 8),
                const Text('Zihninizdeki soruyu ya da niyeti yazın',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
                const SizedBox(height: 32),
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
                          'Niyetinizi veya sorunuzu yazın...\n(Ör: Aşk hayatım hakkında bilmek istiyorum)',
                      hintStyle: TextStyle(
                          color: AppTheme.muted, fontSize: 13, height: 1.5),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _intent.trim().isEmpty
                      ? null
                      : () => setState(() => _step = 1),
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: _intent.trim().isEmpty
                          ? null
                          : const LinearGradient(
                              colors: [AppTheme.gold, AppTheme.violet]),
                      color: _intent.trim().isEmpty
                          ? AppTheme.muted.withOpacity(0.2)
                          : null,
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: _intent.trim().isEmpty
                          ? []
                          : [
                              BoxShadow(
                                  color: AppTheme.violet.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5))
                            ],
                    ),
                    child: const Center(
                        child: Text('Devam Et →',
                            style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 1))),
                  ),
                ),
              ],

              // ADIM 1: Karıştır
              if (_step == 1) ...[
                const Text(
                    '"Kartları 3 kez karıştırın, niyetinize odaklanın..."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _shuffleAnimation,
                  builder: (context, child) => Transform.rotate(
                    angle: _shuffleAnimation.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: List.generate(
                          5,
                          (i) => Transform.translate(
                                offset: Offset((i - 2) * 8.0, 0),
                                child: _buildCardBack(width: 70, height: 100),
                              )),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        3,
                        (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < _shuffleCount
                                    ? AppTheme.gold
                                    : AppTheme.muted.withOpacity(0.3),
                                border: Border.all(
                                    color: AppTheme.gold.withOpacity(0.5)),
                              ),
                              child: i < _shuffleCount
                                  ? const Icon(Icons.check,
                                      size: 10, color: Colors.white)
                                  : null,
                            ))),
                const SizedBox(height: 8),
                Text('${_shuffleCount}/3 karıştırma',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppTheme.muted)),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _shuffle,
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
                        child: Text('🔀 Karıştır',
                            style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 1))),
                  ),
                ),
              ],

              // ADIM 2: Kes
              if (_step == 2) ...[
                const Text(
                    '"Kartları 3 kez kesin, her kesimde niyetinizi hissedin..."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                      3,
                      (i) => GestureDetector(
                            onTap: _cutCount < 3 ? _cut : null,
                            child: Column(children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: Stack(children: [
                                  _buildCardBack(width: 70, height: 100),
                                  _buildCardBack(width: 70, height: 100),
                                  _buildCardBack(width: 70, height: 100),
                                ]),
                              ),
                              const SizedBox(height: 8),
                              Text('Grup ${i + 1}',
                                  style: const TextStyle(
                                      fontFamily: 'Cinzel',
                                      fontSize: 10,
                                      color: AppTheme.muted)),
                            ]),
                          )),
                ),
                const SizedBox(height: 32),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        3,
                        (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < _cutCount
                                    ? AppTheme.gold
                                    : AppTheme.muted.withOpacity(0.3),
                                border: Border.all(
                                    color: AppTheme.gold.withOpacity(0.5)),
                              ),
                              child: i < _cutCount
                                  ? const Icon(Icons.check,
                                      size: 10, color: Colors.white)
                                  : null,
                            ))),
                const SizedBox(height: 8),
                Text('${_cutCount}/3 kesme',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppTheme.muted)),
                const SizedBox(height: 8),
                const Text('Gruplardan birine dokunun',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppTheme.muted)),
              ],

              // ADIM 3 & 4: Kartlar
              if (_step >= 3 && _drawnCards.isNotEmpty) ...[
                const Text('7 Kart Açılımı',
                    style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 14,
                        color: AppTheme.gold,
                        letterSpacing: 1)),
                const SizedBox(height: 20),
                // Üst 4 kart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                      4,
                      (i) => AnimatedBuilder(
                            animation: _cardControllers[i],
                            builder: (context, child) {
                              final angle = _cardControllers[i].value * pi;
                              final showFront = angle > pi / 2;
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(
                                      angle > pi / 2 ? pi - angle : angle),
                                child: Column(children: [
                                  showFront
                                      ? _buildCardFace(_drawnCards[i])
                                      : _buildCardBack(),
                                  const SizedBox(height: 4),
                                  Text(_positions[i],
                                      style: const TextStyle(
                                          fontFamily: 'Cinzel',
                                          fontSize: 8,
                                          color: AppTheme.muted)),
                                ]),
                              );
                            },
                          )),
                ),
                const SizedBox(height: 12),
                // Alt 3 kart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                      3,
                      (i) => AnimatedBuilder(
                            animation: _cardControllers[i + 4],
                            builder: (context, child) {
                              final angle = _cardControllers[i + 4].value * pi;
                              final showFront = angle > pi / 2;
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(
                                      angle > pi / 2 ? pi - angle : angle),
                                child: Column(children: [
                                  showFront
                                      ? _buildCardFace(_drawnCards[i + 4])
                                      : _buildCardBack(),
                                  const SizedBox(height: 4),
                                  Text(_positions[i + 4],
                                      style: const TextStyle(
                                          fontFamily: 'Cinzel',
                                          fontSize: 8,
                                          color: AppTheme.muted)),
                                ]),
                              );
                            },
                          )),
                ),
                const SizedBox(height: 24),

                if (_step == 4) ...[
                  // Kart detayları
                  ...List.generate(7, (i) {
                    final suit = _drawnCards[i]['suit'] as Map<String, dynamic>;
                    final value = _drawnCards[i]['value'] as String;
                    final isRed = suit['isRed'] as bool;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppTheme.purple1.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppTheme.purple3.withOpacity(0.3))),
                      child: Row(children: [
                        Container(
                          width: 42,
                          height: 58,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: AppTheme.gold.withOpacity(0.4))),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(suit['symbol'] as String,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            isRed ? Colors.red : Colors.black)),
                                Text(value,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isRed ? Colors.red : Colors.black)),
                              ]),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(_positions[i],
                                  style: const TextStyle(
                                      fontFamily: 'Cinzel',
                                      fontSize: 9,
                                      color: AppTheme.gold)),
                              Text('${suit['name']} $value',
                                  style: const TextStyle(
                                      fontFamily: 'Cinzel',
                                      fontSize: 12,
                                      color: AppTheme.white)),
                              Text(_valueMeanings[value] ?? '',
                                  style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 10,
                                      color: AppTheme.muted)),
                            ])),
                      ]),
                    );
                  }),
                  const SizedBox(height: 16),

                  if (_loading) ...[
                    const CircularProgressIndicator(
                        color: AppTheme.gold, strokeWidth: 2),
                    const SizedBox(height: 12),
                    const Text('Kartlar yorumlanıyor... 🎴✨',
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
                            fortuneType: 'İskambil Falı',
                            fortuneEmoji: '🎴',
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
                            fortuneType: 'İskambil Falı',
                            fortuneEmoji: '🎴',
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
                                child: Text('🔄 Yeni Fal Bak',
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
                                child: Text('🔄 Başa Dön',
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
