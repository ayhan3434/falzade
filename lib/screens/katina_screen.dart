import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class KatinaScreen extends StatefulWidget {
  const KatinaScreen({super.key});

  @override
  State<KatinaScreen> createState() => _KatinaScreenState();
}

class _KatinaScreenState extends State<KatinaScreen>
    with TickerProviderStateMixin {
  final _random = Random();

  // Katina falı gerçek 40 kartlık Mısır destesidir
  static const _cards = [
    {
      'name': 'Güneş',
      'emoji': '☀️',
      'meaning': 'Başarı, zafer ve aydınlık. Her şey yolunda gidecek.'
    },
    {
      'name': 'Ay',
      'emoji': '🌙',
      'meaning': 'Gizem, sezgi ve kadın enerjisi. Dikkatli ol.'
    },
    {
      'name': 'Yıldız',
      'emoji': '⭐',
      'meaning': 'Umut, şans ve ilahi rehberlik. İyi haberler geliyor.'
    },
    {
      'name': 'Ölüm',
      'emoji': '💀',
      'meaning': 'Dönüşüm ve yenilenme. Bir şey sona eriyor, yenisi başlıyor.'
    },
    {
      'name': 'Aşk',
      'emoji': '❤️',
      'meaning': 'Derin bağ, aşk ve tutku. Kalp işleri öne çıkıyor.'
    },
    {
      'name': 'Kader',
      'emoji': '☸️',
      'meaning': 'Yazgı ve döngü. Geçmiş şimdiyi şekillendiriyor.'
    },
    {
      'name': 'Güç',
      'emoji': '🦁',
      'meaning': 'İç güç ve cesaret. Zorlukların üstesinden geleceksin.'
    },
    {
      'name': 'Adalet',
      'emoji': '⚖️',
      'meaning': 'Denge, hakkaniyet ve doğruluk. Hak yerini bulacak.'
    },
    {
      'name': 'Kule',
      'emoji': '🏰',
      'meaning': 'Ani değişim ve uyanış. Sarsılma ama yıkılmama.'
    },
    {
      'name': 'Ermiş',
      'emoji': '🕯️',
      'meaning': 'Bilgelik, içe dönüş ve rehber. Yalnız yolculuk.'
    },
    {
      'name': 'İmparator',
      'emoji': '👑',
      'meaning': 'Otorite, güç ve liderlik. Kontrolü ele al.'
    },
    {
      'name': 'İmparatoriçe',
      'emoji': '🌸',
      'meaning': 'Bereket, yaratıcılık ve doğa. Bolluk zamanı.'
    },
    {
      'name': 'Büyücü',
      'emoji': '🎩',
      'meaning': 'Beceri, irade ve dönüşüm gücü. Elinde araçlar var.'
    },
    {
      'name': 'Rahibe',
      'emoji': '🌙',
      'meaning': 'Sezgi, gizem ve bilinçaltı. Derin bilgelik sende.'
    },
    {
      'name': 'Asılı Adam',
      'emoji': '🙃',
      'meaning': 'Bekleme, fedakarlık ve yeni bakış açısı. Dur ve düşün.'
    },
    {
      'name': 'Ilınma',
      'emoji': '🌊',
      'meaning': 'Denge, sabır ve uyum. Akan suya dayan.'
    },
    {
      'name': 'Şeytan',
      'emoji': '😈',
      'meaning': 'Bağımlılık, takıntı ve maddeye esaret. Özgürleş.'
    },
    {
      'name': 'Aptal',
      'emoji': '🃏',
      'meaning': 'Yeni başlangıç, serüven ve saf enerji. Atlama yap.'
    },
    {
      'name': 'Savaş Arabası',
      'emoji': '🏆',
      'meaning': 'Zafer, kontrol ve ilerleme. Başarı yakın.'
    },
    {
      'name': 'Dünya',
      'emoji': '🌍',
      'meaning': 'Tamamlanma, bütünlük ve kutlama. Döngü kapanıyor.'
    },
    {
      'name': 'Yargı',
      'emoji': '📯',
      'meaning': 'Uyanış, yenilenme ve hesaplaşma. Geçmişle yüzleş.'
    },
    {
      'name': 'Aşıklar',
      'emoji': '💑',
      'meaning': 'Seçim, uyum ve bağlılık. Kalpten karar ver.'
    },
    {
      'name': 'Başrahip',
      'emoji': '✝️',
      'meaning': 'Gelenek, rehberlik ve manevi öğreti. Bilgeden öğren.'
    },
    {
      'name': 'Mısır Sfenksi',
      'emoji': '🗿',
      'meaning': 'Antik bilgelik ve sır. Cevap içinde saklı.'
    },
    {
      'name': 'Nil Nehri',
      'emoji': '🌊',
      'meaning': 'Bereket, yaşam kaynağı ve akış. Her şey doğal seyrinde.'
    },
    {
      'name': 'Piramit',
      'emoji': '🔺',
      'meaning': 'Güç, kalıcılık ve yüksek hedefler. Zirveye tırman.'
    },
    {
      'name': 'Lotus',
      'emoji': '🌺',
      'meaning': 'Arınma, ruhsal uyanış ve güzellik. Çamurdan doğ.'
    },
    {
      'name': 'Horus',
      'emoji': '👁️',
      'meaning': 'Koruma, görüş ve ilahi gözetim. İzleniyorsun.'
    },
    {
      'name': 'Anubis',
      'emoji': '🐺',
      'meaning': 'Geçiş, koruma ve dönüşüm rehberi. Bir geçiş döneminde.'
    },
    {
      'name': 'Ra',
      'emoji': '🌅',
      'meaning': 'İlahi güç, yaratım ve enerji. Güneş gibi parla.'
    },
    {
      'name': 'İsis',
      'emoji': '🦅',
      'meaning': 'Büyü, şifa ve anne sevgisi. Güçlü kadın enerjisi.'
    },
    {
      'name': 'Osiris',
      'emoji': '🌿',
      'meaning': 'Yeniden doğuş, adalet ve bereket. Her son yeni bir başlangıç.'
    },
    {
      'name': 'Thoth',
      'emoji': '📜',
      'meaning': 'Bilgelik, yazı ve ilahi mesaj. Bilgi güçtür.'
    },
    {
      'name': 'Bastet',
      'emoji': '🐱',
      'meaning': 'Koruma, ev ve kadın gücü. Ev huzuru önemli.'
    },
    {
      'name': 'Scarab',
      'emoji': '🪲',
      'meaning': 'Dönüşüm, şans ve yenilenme. Güneş böceği gibi yüksel.'
    },
    {
      'name': 'Çöl',
      'emoji': '🏜️',
      'meaning':
          'Sınav, yalnızlık ve içsel yolculuk. Bu süreç seni güçlendirecek.'
    },
    {
      'name': 'Altın',
      'emoji': '💛',
      'meaning': 'Zenginlik, değer ve ödül. Maddi kazanç geliyor.'
    },
    {
      'name': 'Papirüs',
      'emoji': '📃',
      'meaning': 'Yeni sayfa, yazgı ve sözleşme. Yeni bir dönem başlıyor.'
    },
    {
      'name': 'Firavun',
      'emoji': '🤴',
      'meaning':
          'Yüksek güç, otorite ve ilahi krallık. Büyük bir güç seni destekliyor.'
    },
    {
      'name': 'Mumya',
      'emoji': '🧟',
      'meaning': 'Geçmişin gölgesi, eski yükler ve dönüşüm. Geçmişi bırak.'
    },
  ];

  static const _positions = [
    'Geçmiş',
    'Şimdi',
    'Gelecek',
    'Gizli Etken',
    'Sonuç'
  ];
  static const _positionDescs = [
    'Seni buraya getiren',
    'Şu anki durum',
    'Yakında gelecek',
    'Gizli bir etki',
    'Olası sonuç',
  ];

  List<Map<String, dynamic>> _drawnCards = [];
  bool _loading = false;
  String? _result;
  late List<AnimationController> _flipControllers;
  late List<Animation<double>> _flipAnimations;
  bool _cardsDrawn = false;
  List<bool> _revealed = List.filled(5, false);

  @override
  void initState() {
    super.initState();
    _flipControllers = List.generate(
        5,
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
      _drawnCards = shuffled.take(5).toList();
      _revealed = List.filled(5, false);
      _result = null;
      _cardsDrawn = true;
    });
    for (int i = 0; i < 5; i++) {
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
            5,
            (i) =>
                '${_positions[i]} (${_positionDescs[i]}): ${_drawnCards[i]['name']} - ${_drawnCards[i]['meaning']}')
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
          'max_tokens': 600,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Antik Mısır Katina falı yorumu yap. Bu fal 5 kartlı özel bir Mısır kehanet sistemidir. Çekilen kartlar:\n$cardDesc\n\nHer kartı pozisyonuna göre Mısır mistisizmi geleneğiyle yorumla. Kartların birlikte anlattığı hikayeyi de açıkla. Türkçe, 6-7 cümle, mistik ve şiirsel ol, emoji kullan, markdown kullanma.'
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
          _result = 'Mısır kehaneti şu an sessiz... 🌙';
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
      _revealed = List.filled(5, false);
      _drawnCards = [];
    });
    for (final c in _flipControllers) c.reset();
  }

  Widget _buildCard(int index) {
    return AnimatedBuilder(
      animation: _flipAnimations[index],
      builder: (context, child) {
        final angle = _flipAnimations[index].value * pi;
        final showFront = angle > pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle > pi / 2 ? pi - angle : angle),
          child: Container(
            width: 58,
            height: 90,
            decoration: BoxDecoration(
              gradient: showFront
                  ? const LinearGradient(
                      colors: [Color(0xFF8B6914), Color(0xFF4A3000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight)
                  : const LinearGradient(
                      colors: [Color(0xFF2D1654), Color(0xFF1A4060)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppTheme.gold.withOpacity(showFront ? 0.8 : 0.4),
                  width: 1.5),
              boxShadow: [
                BoxShadow(color: AppTheme.gold.withOpacity(0.3), blurRadius: 10)
              ],
            ),
            child: showFront && _drawnCards.length > index
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text(_drawnCards[index]['emoji'] as String,
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(_drawnCards[index]['name'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 7,
                                  color: AppTheme.gold),
                              maxLines: 2),
                        ),
                      ])
                : const Center(
                    child: Text('𓂀',
                        style: TextStyle(fontSize: 22, color: AppTheme.gold))),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0800),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppTheme.gold, size: 20),
            onPressed: () => Navigator.pop(context)),
        title: ShaderMask(
          shaderCallback: (bounds) => AppTheme.goldToLilac.createShader(bounds),
          child: const Text('📜 Katina Falı',
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
              const Text('Antik Mısır Kehaneti',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 8),
              const Text('5 Kartlı Mısır Açılımı',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 13,
                      color: AppTheme.muted)),
              const SizedBox(height: 32),
              if (!_cardsDrawn) ...[
                const Text('𓂀',
                    style: TextStyle(fontSize: 80, color: AppTheme.gold)),
                const SizedBox(height: 16),
                const Text('"Firavunların kehaneti seninle..."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
                const SizedBox(height: 8),
                const Text(
                    '40 Mısır kartından 5 kart çekeceksin\nGeçmiş • Şimdi • Gelecek • Gizli Etken • Sonuç',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppTheme.muted,
                        height: 1.6)),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _drawCards,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFB8860B), Color(0xFF8B6914)]),
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.gold.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5))
                      ],
                    ),
                    child: const Center(
                        child: Text('𓂀 Kartları Çek',
                            style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 1))),
                  ),
                ),
              ] else ...[
                // 5 kart - üstte 3, altta 2
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                          3,
                          (i) => Column(children: [
                                _buildCard(i),
                                const SizedBox(height: 6),
                                Text(_positions[i],
                                    style: const TextStyle(
                                        fontFamily: 'Cinzel',
                                        fontSize: 8,
                                        color: AppTheme.gold)),
                              ])),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [3, 4]
                          .map((i) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(children: [
                                  _buildCard(i),
                                  const SizedBox(height: 6),
                                  Text(_positions[i],
                                      style: const TextStyle(
                                          fontFamily: 'Cinzel',
                                          fontSize: 8,
                                          color: AppTheme.gold)),
                                ]),
                              ))
                          .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (_revealed[4] && _drawnCards.length == 5) ...[
                  ...List.generate(
                      5,
                      (i) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1000).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppTheme.gold.withOpacity(0.3)),
                            ),
                            child: Row(children: [
                              Container(
                                width: 44,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    Color(0xFF8B6914),
                                    Color(0xFF4A3000)
                                  ]),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppTheme.gold.withOpacity(0.5)),
                                ),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(_drawnCards[i]['emoji'] as String,
                                          style: const TextStyle(fontSize: 18)),
                                      Text(_positions[i],
                                          style: const TextStyle(
                                              fontFamily: 'Cinzel',
                                              fontSize: 6,
                                              color: AppTheme.gold)),
                                    ]),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(_drawnCards[i]['name'] as String,
                                        style: const TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 12,
                                            color: AppTheme.gold)),
                                    const SizedBox(height: 2),
                                    Text(_positionDescs[i],
                                        style: const TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 9,
                                            color: AppTheme.muted)),
                                    const SizedBox(height: 2),
                                    Text(_drawnCards[i]['meaning'] as String,
                                        style: const TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 10,
                                            color: Colors.white70,
                                            height: 1.3)),
                                  ])),
                            ]),
                          )),
                  const SizedBox(height: 16),
                  if (_loading) ...[
                    const CircularProgressIndicator(
                        color: AppTheme.gold, strokeWidth: 2),
                    const SizedBox(height: 12),
                    const Text('Mısır kehaneti okunuyor... 𓂀✨',
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
                        color: const Color(0xFF1A1000).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: AppTheme.gold.withOpacity(0.4)),
                      ),
                      child: Text(_result!,
                          style: const TextStyle(
                              fontFamily: 'Cormorant Garamond',
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.amber,
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
                            fortuneType: 'Katina Falı',
                            fortuneEmoji: '📜',
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
                              gradient: const LinearGradient(colors: [
                                Color(0xFFB8860B),
                                Color(0xFF8B6914)
                              ]),
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
                            fortuneType: 'Katina Falı',
                            fortuneEmoji: '📜',
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
                                  color: AppTheme.gold.withOpacity(0.4)),
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
                              colors: [Color(0xFFB8860B), Color(0xFF8B6914)]),
                          borderRadius: BorderRadius.circular(27),
                          boxShadow: [
                            BoxShadow(
                                color: AppTheme.gold.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5))
                          ],
                        ),
                        child: const Center(
                            child: Text('𓂀 Kehaneti Oku',
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
