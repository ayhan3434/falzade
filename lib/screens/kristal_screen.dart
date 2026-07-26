import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class KristalScreen extends StatefulWidget {
  const KristalScreen({super.key});

  @override
  State<KristalScreen> createState() => _KristalScreenState();
}

class _KristalScreenState extends State<KristalScreen>
    with TickerProviderStateMixin {
  String? _selectedSign;
  bool _loading = false;
  String? _result;
  Map<String, dynamic>? _crystalData;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
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

  // Her burç için önerilen kristaller
  static const _signCrystals = {
    '♈ Koç': [
      {
        'name': 'Kırmızı Jasper',
        'emoji': '🔴',
        'color': 0xFFB71C1C,
        'desc': 'Güç ve cesaret taşı'
      },
      {
        'name': 'Karneol',
        'emoji': '🟠',
        'color': 0xFFE65100,
        'desc': 'Motivasyon ve yaratıcılık'
      },
      {
        'name': 'Sitrin',
        'emoji': '💛',
        'color': 0xFFF9A825,
        'desc': 'Enerji ve özgüven'
      },
    ],
    '♉ Boğa': [
      {
        'name': 'Yeşil Aventurin',
        'emoji': '💚',
        'color': 0xFF2E7D32,
        'desc': 'Bolluk ve şans taşı'
      },
      {
        'name': 'Roze Kuvars',
        'emoji': '🌸',
        'color': 0xFFF06292,
        'desc': 'Sevgi ve huzur'
      },
      {
        'name': 'Malakit',
        'emoji': '🟢',
        'color': 0xFF1B5E20,
        'desc': 'Dönüşüm ve iyileşme'
      },
    ],
    '♊ İkizler': [
      {
        'name': 'Akik',
        'emoji': '⚪',
        'color': 0xFF546E7A,
        'desc': 'Denge ve uyum taşı'
      },
      {
        'name': 'Sitrin',
        'emoji': '💛',
        'color': 0xFFF9A825,
        'desc': 'Zeka ve iletişim'
      },
      {
        'name': 'Lapis Lazuli',
        'emoji': '💙',
        'color': 0xFF1565C0,
        'desc': 'Bilgelik ve sezgi'
      },
    ],
    '♋ Yengeç': [
      {
        'name': 'Ay Taşı',
        'emoji': '🌙',
        'color': 0xFF90A4AE,
        'desc': 'Sezgi ve koruma taşı'
      },
      {
        'name': 'İnci',
        'emoji': '⚪',
        'color': 0xFFECEFF1,
        'desc': 'Saflık ve berraklık'
      },
      {
        'name': 'Roze Kuvars',
        'emoji': '🌸',
        'color': 0xFFF06292,
        'desc': 'Duygusal şifa'
      },
    ],
    '♌ Aslan': [
      {
        'name': 'Sitrin',
        'emoji': '💛',
        'color': 0xFFF9A825,
        'desc': 'Güç ve başarı taşı'
      },
      {
        'name': 'Pirit',
        'emoji': '✨',
        'color': 0xFFFFD600,
        'desc': 'Bolluk ve özgüven'
      },
      {
        'name': 'Kaplan Gözü',
        'emoji': '🟤',
        'color': 0xFF6D4C41,
        'desc': 'Cesaret ve kararlılık'
      },
    ],
    '♍ Başak': [
      {
        'name': 'Ametist',
        'emoji': '💜',
        'color': 0xFF6A1B9A,
        'desc': 'Arınma ve netlik taşı'
      },
      {
        'name': 'Yeşim',
        'emoji': '💚',
        'color': 0xFF388E3C,
        'desc': 'Sağlık ve denge'
      },
      {
        'name': 'Sardoniks',
        'emoji': '🟠',
        'color': 0xFFBF360C,
        'desc': 'Disiplin ve odaklanma'
      },
    ],
    '♎ Terazi': [
      {
        'name': 'Roze Kuvars',
        'emoji': '🌸',
        'color': 0xFFF06292,
        'desc': 'Sevgi ve denge taşı'
      },
      {
        'name': 'Lapis Lazuli',
        'emoji': '💙',
        'color': 0xFF1565C0,
        'desc': 'Adalet ve uyum'
      },
      {
        'name': 'Opal',
        'emoji': '🌈',
        'color': 0xFF80DEEA,
        'desc': 'Yaratıcılık ve ilham'
      },
    ],
    '♏ Akrep': [
      {
        'name': 'Obsidyen',
        'emoji': '⚫',
        'color': 0xFF212121,
        'desc': 'Koruma ve dönüşüm taşı'
      },
      {
        'name': 'Labradorit',
        'emoji': '🔵',
        'color': 0xFF1A237E,
        'desc': 'Mistisizm ve sezgi'
      },
      {
        'name': 'Malakit',
        'emoji': '🟢',
        'color': 0xFF1B5E20,
        'desc': 'Güç ve iyileşme'
      },
    ],
    '♐ Yay': [
      {
        'name': 'Turkuaz',
        'emoji': '🩵',
        'color': 0xFF00838F,
        'desc': 'Şans ve özgürlük taşı'
      },
      {
        'name': 'Sodalit',
        'emoji': '💙',
        'color': 0xFF1A237E,
        'desc': 'Bilgelik ve gerçek'
      },
      {
        'name': 'Sitrin',
        'emoji': '💛',
        'color': 0xFFF9A825,
        'desc': 'Neşe ve bolluk'
      },
    ],
    '♑ Oğlak': [
      {
        'name': 'Oniks',
        'emoji': '⚫',
        'color': 0xFF37474F,
        'desc': 'Güç ve kararlılık taşı'
      },
      {
        'name': 'Garnet',
        'emoji': '🔴',
        'color': 0xFF880E4F,
        'desc': 'Başarı ve tutku'
      },
      {
        'name': 'Kaplan Gözü',
        'emoji': '🟤',
        'color': 0xFF6D4C41,
        'desc': 'Pratiklik ve odak'
      },
    ],
    '♒ Kova': [
      {
        'name': 'Ametist',
        'emoji': '💜',
        'color': 0xFF6A1B9A,
        'desc': 'Sezgi ve yenilik taşı'
      },
      {
        'name': 'Akuamarin',
        'emoji': '🩵',
        'color': 0xFF006064,
        'desc': 'Berraklık ve huzur'
      },
      {
        'name': 'Labradorit',
        'emoji': '🔵',
        'color': 0xFF1A237E,
        'desc': 'Değişim ve ilham'
      },
    ],
    '♓ Balık': [
      {
        'name': 'Akuamarin',
        'emoji': '🩵',
        'color': 0xFF006064,
        'desc': 'Ruhsallık ve huzur taşı'
      },
      {
        'name': 'Ametist',
        'emoji': '💜',
        'color': 0xFF6A1B9A,
        'desc': 'Sezgi ve şifa'
      },
      {
        'name': 'Ay Taşı',
        'emoji': '🌙',
        'color': 0xFF90A4AE,
        'desc': 'Hayal gücü ve mistisizm'
      },
    ],
  };

  // Bugünkü enerji (güne göre değişir)
  Map<String, dynamic> _getTodayEnergy() {
    final now = DateTime.now();
    final energies = [
      {
        'name': 'Yaratıcılık Enerjisi',
        'emoji': '✨',
        'desc': 'Bugün yaratıcı güçler yüksek'
      },
      {
        'name': 'Şifa Enerjisi',
        'emoji': '💚',
        'desc': 'Bugün iyileşme ve dinlenme günü'
      },
      {
        'name': 'Bolluk Enerjisi',
        'emoji': '🌟',
        'desc': 'Bugün bereket ve şans enerjisi var'
      },
      {
        'name': 'Sevgi Enerjisi',
        'emoji': '💗',
        'desc': 'Bugün kalp çakrası açık'
      },
      {
        'name': 'Güç Enerjisi',
        'emoji': '🔥',
        'desc': 'Bugün eylem ve güç günü'
      },
      {'name': 'Sezgi Enerjisi', 'emoji': '🔮', 'desc': 'Bugün sezgiler güçlü'},
      {
        'name': 'Dönüşüm Enerjisi',
        'emoji': '🦋',
        'desc': 'Bugün değişim ve büyüme zamanı'
      },
    ];
    return energies[now.weekday - 1];
  }

  // Burca göre en uygun kristali seç
  Map<String, dynamic> _getRecommendedCrystal(String sign) {
    final crystals = _signCrystals[sign]!;
    final energy = _getTodayEnergy();
    // Güne göre farklı kristal öner
    final index = DateTime.now().day % crystals.length;
    return {...crystals[index], 'energy': energy};
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
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();
    _rotateAnimation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_rotateController);
  }

  @override
  void dispose() {
    _glowController.dispose();
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

    final crystal = _getRecommendedCrystal(_selectedSign!);
    setState(() {
      _crystalData = crystal;
      _loading = true;
    });
    final energy = _getTodayEnergy();

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
                  'Kristal falı yorumu yap.\n\nDoğum Burcu: $_selectedSign\nÖnerilen Kristal: ${crystal['name']} ${crystal['emoji']}\nKristalin Anlamı: ${crystal['desc']}\nBugünkü Enerji: ${energy['name']} ${energy['emoji']} - ${energy['desc']}\n\nBu kristali bu burç için neden önerdiğini, kristalin bu kişiye nasıl yardımcı olacağını ve bugünkü enerjiyle nasıl uyum sağladığını mistik ve şiirsel şekilde anlat. Kristalin nasıl kullanılacağına dair ipucu ver. Türkçe, 6-7 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Kristaller şu an sessiz... 💎';
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
      _crystalData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final crystalColor = _crystalData != null
        ? Color(_crystalData!['color'] as int)
        : AppTheme.violet;

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
          child: const Text('💎 Kristal Falı',
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
              const Text('Kristallerin Gizemi',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 24),

              // Kristal animasyonu
              AnimatedBuilder(
                animation: Listenable.merge([_glowAnimation, _rotateAnimation]),
                builder: (context, child) => Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dönen halka
                    Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: crystalColor
                                  .withOpacity(0.3 * _glowAnimation.value),
                              width: 1),
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: -_rotateAnimation.value * 0.7,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppTheme.gold
                                  .withOpacity(0.2 * _glowAnimation.value),
                              width: 1),
                        ),
                      ),
                    ),
                    // Glow
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: crystalColor
                                  .withOpacity(0.4 * _glowAnimation.value),
                              blurRadius: 40,
                              spreadRadius: 10),
                          BoxShadow(
                              color: AppTheme.violet
                                  .withOpacity(0.2 * _glowAnimation.value),
                              blurRadius: 60,
                              spreadRadius: 20),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _crystalData != null
                              ? _crystalData!['emoji'] as String
                              : '💎',
                          style: const TextStyle(fontSize: 65),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Bugünkü enerji
              Builder(builder: (context) {
                final energy = _getTodayEnergy();
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.purple1.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(energy['emoji'] as String,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bugünün Enerjisi: ${energy['name']}',
                              style: const TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 10,
                                  color: AppTheme.gold)),
                          Text(energy['desc'] as String,
                              style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 10,
                                  color: AppTheme.muted)),
                        ]),
                  ]),
                );
              }),
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
                const SizedBox(height: 16),

                // Seçilen burç için kristalleri göster
                if (_selectedSign != null) ...[
                  const Text('Size Önerilen Kristaller',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 12,
                          color: AppTheme.muted,
                          letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Row(
                    children: (_signCrystals[_selectedSign!]!).map((crystal) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                Color(crystal['color'] as int).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Color(crystal['color'] as int)
                                    .withOpacity(0.4)),
                          ),
                          child: Column(children: [
                            Text(crystal['emoji'] as String,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 4),
                            Text(crystal['name'] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 8,
                                    color: AppTheme.white)),
                            const SizedBox(height: 2),
                            Text(crystal['desc'] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 8,
                                    color: AppTheme.muted)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_loading) ...[
                  const CircularProgressIndicator(
                      color: AppTheme.gold, strokeWidth: 2),
                  const SizedBox(height: 12),
                  const Text('Kristaller titreşiyor... 💎✨',
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
                            colors: [Color(0xFF6A1B9A), AppTheme.violet]),
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.violet.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: const Center(
                          child: Text('💎 Kristalimi Bul',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 1))),
                    ),
                  ),
                ],
              ] else ...[
                // Önerilen kristal kartı
                if (_crystalData != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: crystalColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: crystalColor.withOpacity(0.4)),
                    ),
                    child: Row(children: [
                      Text(_crystalData!['emoji'] as String,
                          style: const TextStyle(fontSize: 48)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text('Bugünkü Kristaliniz',
                                style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 10,
                                    color: crystalColor)),
                            const SizedBox(height: 4),
                            Text(_crystalData!['name'] as String,
                                style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 16,
                                    color: crystalColor,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(_crystalData!['desc'] as String,
                                style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 11,
                                    color: AppTheme.muted)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: AppTheme.gold.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text('$_selectedSign',
                                  style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 10,
                                      color: AppTheme.gold)),
                            ),
                          ])),
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
                      crystalColor.withOpacity(0.08),
                      AppTheme.purple1.withOpacity(0.6)
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: crystalColor.withOpacity(0.2)),
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
                        fortuneType: 'Kristal Falı',
                        fortuneEmoji: '💎',
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
                        fortuneType: 'Kristal Falı',
                        fortuneEmoji: '💎',
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
                            child: Text('🔄 Yeni Kristal Bul',
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
