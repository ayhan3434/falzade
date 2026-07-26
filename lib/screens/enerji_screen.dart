import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class EnerjiScreen extends StatefulWidget {
  const EnerjiScreen({super.key});

  @override
  State<EnerjiScreen> createState() => _EnerjiScreenState();
}

class _EnerjiScreenState extends State<EnerjiScreen>
    with TickerProviderStateMixin {
  String? _selectedSign;
  bool _loading = false;
  String? _result;
  Map<String, dynamic>? _energyReading;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  static const _signs = [
    '♈ Koç',
    '♉ Boğa',
    '♊ İkizler',
    '♋ Yengeç',
    '♌ Aslan',
    '♍ Başak',
    '♎ Terazi',
    '♏ Akrep',
    '♐ Yay',
    '♑ Oğlak',
    '♒ Kova',
    '♓ Balık',
  ];

  static const _chakras = [
    {
      'name': 'Kök Çakra',
      'emoji': '🔴',
      'color': 0xFFB71C1C,
      'desc': 'Güvenlik ve temel'
    },
    {
      'name': 'Sakral Çakra',
      'emoji': '🟠',
      'color': 0xFFE65100,
      'desc': 'Yaratıcılık ve duygu'
    },
    {
      'name': 'Solar Çakra',
      'emoji': '💛',
      'color': 0xFFF9A825,
      'desc': 'Güç ve özgüven'
    },
    {
      'name': 'Kalp Çakra',
      'emoji': '💚',
      'color': 0xFF2E7D32,
      'desc': 'Sevgi ve şifa'
    },
    {
      'name': 'Boğaz Çakra',
      'emoji': '🔵',
      'color': 0xFF1565C0,
      'desc': 'İletişim ve ifade'
    },
    {
      'name': 'Üçüncü Göz',
      'emoji': '💜',
      'color': 0xFF6A1B9A,
      'desc': 'Sezgi ve bilgelik'
    },
    {
      'name': 'Taç Çakra',
      'emoji': '⚪',
      'color': 0xFF7E57C2,
      'desc': 'Ruhsal bağlantı'
    },
  ];

  static const _auraColors = [
    {'color': '🔴 Kırmızı', 'meaning': 'Güçlü, tutkulu ve enerjik bir gün'},
    {'color': '🟠 Turuncu', 'meaning': 'Yaratıcı ve sosyal enerjiler yüksek'},
    {'color': '💛 Sarı', 'meaning': 'Zihinsel netlik ve özgüven günü'},
    {'color': '💚 Yeşil', 'meaning': 'Şifa ve büyüme enerjisi hakim'},
    {'color': '🔵 Mavi', 'meaning': 'Huzur ve iletişim enerjisi güçlü'},
    {'color': '💜 Mor', 'meaning': 'Ruhsal uyanış ve sezgi günü'},
    {'color': '⚪ Beyaz', 'meaning': 'Arınma ve yeni başlangıç enerjisi'},
  ];

  Map<String, dynamic> _getEnergyReading() {
    final now = DateTime.now();
    final random = Random(now.day + now.month * 31);

    // Aktif çakralar (2-3 tane)
    final chakraCount = 2 + random.nextInt(2);
    final shuffledChakras = List.from(_chakras)..shuffle(random);
    final activeChakras = shuffledChakras.take(chakraCount).toList();

    // Aura rengi
    final auraIndex = (now.day + now.weekday) % _auraColors.length;
    final aura = _auraColors[auraIndex];

    // Enerji seviyesi
    final energyLevel = 40 + random.nextInt(60);

    // Uyarı çakra
    final warningChakra = shuffledChakras.last;

    return {
      'activeChakras': activeChakras,
      'aura': aura,
      'energyLevel': energyLevel,
      'warningChakra': warningChakra,
    };
  }

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _rotateController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();
    _rotateAnimation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_rotateController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _getReading() async {
    if (_selectedSign == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen doğum burcunuzu seçin'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    final reading = _getEnergyReading();
    setState(() {
      _energyReading = reading;
      _loading = true;
    });

    final activeChakraNames = (reading['activeChakras'] as List)
        .map((c) => '${c['emoji']} ${c['name']} (${c['desc']})')
        .join(', ');

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
                  'Enerji ve aura falı yorumu yap.\n\nDoğum Burcu: $_selectedSign\nAura Rengi: ${reading['aura']['color']}\nAura Anlamı: ${reading['aura']['meaning']}\nAktif Çakralar: $activeChakraNames\nEnerji Seviyesi: %${reading['energyLevel']}\nDikkat Çakrası: ${reading['warningChakra']['emoji']} ${reading['warningChakra']['name']}\n\nBu kişinin bugünkü enerji alanını, aurasını ve çakra durumunu mistik ve şiirsel şekilde yorumla. Hangi alanlarda güçlü, hangi alanlarda dikkatli olması gerektiğini anlat. Türkçe, 6-7 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Enerji alanı şu an sessiz... 🌙';
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
      _selectedSign = null;
      _result = null;
      _energyReading = null;
    });
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
          child: const Text('🪬 Enerji Falı',
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
              const Text('Aura ve Çakra Analizi',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 24),

              // Aura animasyonu
              AnimatedBuilder(
                animation:
                    Listenable.merge([_pulseAnimation, _rotateAnimation]),
                builder: (context, child) => SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(alignment: Alignment.center, children: [
                    // Dönen çakra halkaları
                    Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: Container(
                        width: 155,
                        height: 155,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF7C3AED).withOpacity(0.3),
                              width: 1),
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: -_rotateAnimation.value * 0.6,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF00C853).withOpacity(0.3),
                              width: 1),
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: _rotateAnimation.value * 0.4,
                      child: Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFFFAB00).withOpacity(0.3),
                              width: 1),
                        ),
                      ),
                    ),
                    // Merkez
                    Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: AppTheme.violet
                                    .withOpacity(0.5 * _pulseAnimation.value),
                                blurRadius: 30,
                                spreadRadius: 10),
                            BoxShadow(
                                color: const Color(0xFF00C853)
                                    .withOpacity(0.3 * _pulseAnimation.value),
                                blurRadius: 50,
                                spreadRadius: 20),
                          ],
                        ),
                        child: const Center(
                            child: Text('🪬', style: TextStyle(fontSize: 55))),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 24),

              if (_result == null) ...[
                const Text('Doğum Burcunuzu Seçin',
                    style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 13,
                        color: AppTheme.gold,
                        letterSpacing: 1)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.2,
                  children: _signs.map((sign) {
                    final isSelected = _selectedSign == sign;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSign = sign),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [AppTheme.gold, AppTheme.violet])
                              : null,
                          color: isSelected
                              ? null
                              : AppTheme.purple1.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isSelected
                                  ? AppTheme.gold
                                  : AppTheme.purple3.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(sign,
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 11,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.muted,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                if (_loading) ...[
                  const CircularProgressIndicator(
                      color: AppTheme.gold, strokeWidth: 2),
                  const SizedBox(height: 12),
                  const Text('Enerji alanınız taranıyor... 🪬✨',
                      style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.muted)),
                ] else ...[
                  GestureDetector(
                    onTap: _getReading,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF1B5E20), AppTheme.violet]),
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.violet.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: const Center(
                          child: Text('🪬 Enerjimi Analiz Et',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 1))),
                    ),
                  ),
                ],
              ] else ...[
                // Aura kartı
                if (_energyReading != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
                    ),
                    child: Column(children: [
                      // Aura
                      Row(children: [
                        const Text('🌈', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  'Auranız: ${_energyReading!['aura']['color']}',
                                  style: const TextStyle(
                                      fontFamily: 'Cinzel',
                                      fontSize: 11,
                                      color: AppTheme.gold)),
                              Text(_energyReading!['aura']['meaning'] as String,
                                  style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 10,
                                      color: AppTheme.muted)),
                            ])),
                      ]),
                      const SizedBox(height: 12),
                      // Enerji seviyesi
                      Row(children: [
                        const Text('⚡', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  'Enerji Seviyesi: %${_energyReading!['energyLevel']}',
                                  style: const TextStyle(
                                      fontFamily: 'Cinzel',
                                      fontSize: 10,
                                      color: AppTheme.white)),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value:
                                      (_energyReading!['energyLevel'] as int) /
                                          100,
                                  backgroundColor:
                                      AppTheme.purple3.withOpacity(0.3),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppTheme.gold),
                                  minHeight: 6,
                                ),
                              ),
                            ])),
                      ]),
                      const SizedBox(height: 12),
                      // Aktif çakralar
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Aktif Çakralar:',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 10,
                                  color: AppTheme.muted))),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: (_energyReading!['activeChakras'] as List)
                            .map((chakra) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Color(chakra['color'] as int)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Color(chakra['color'] as int)
                                            .withOpacity(0.4)),
                                  ),
                                  child: Text(
                                      '${chakra['emoji']} ${chakra['name']}',
                                      style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 10,
                                          color:
                                              Color(chakra['color'] as int))),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      // Dikkat çakrası
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.redAccent.withOpacity(0.3))),
                        child: Row(children: [
                          const Text('⚠️', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(
                                  'Dikkat: ${_energyReading!['warningChakra']['emoji']} ${_energyReading!['warningChakra']['name']} çakranız dengelenmeye ihtiyaç duyuyor.',
                                  style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 10,
                                      color: Colors.redAccent))),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],

                // AI yorumu
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      const Color(0xFF1B5E20).withOpacity(0.1),
                      AppTheme.purple1.withOpacity(0.6)
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF2E7D32).withOpacity(0.3)),
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
                        fortuneType: 'Enerji Falı',
                        fortuneEmoji: '🪬',
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
                        fortuneType: 'Enerji Falı',
                        fortuneEmoji: '🪬',
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
                            child: Text('🔄 Yeni Analiz',
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
