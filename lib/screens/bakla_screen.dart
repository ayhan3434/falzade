import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class BaklaScreen extends StatefulWidget {
  const BaklaScreen({super.key});

  @override
  State<BaklaScreen> createState() => _BaklaScreenState();
}

class _BaklaScreenState extends State<BaklaScreen>
    with TickerProviderStateMixin {
  final _random = Random();
  final _intentController = TextEditingController();

  // Adımlar: 0=niyet, 1=baklaları say, 2=grupla, 3=yorum
  int _step = 0;
  String _intent = '';
  bool _loading = false;
  String? _result;
  bool _counting = false;

  // Bakla grupları (tek/çift)
  List<int> _groups = []; // her grubun bakla sayısı
  List<bool> _isEven = []; // çift mi tek mi
  int _totalBeans = 0;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Geleneksel bakla anlamları
  static const _evenMeanings = [
    'Hayırlı, olumlu enerji ✨',
    'Kapı açık, devam et 🚪',
    'Evet enerjisi güçlü 💚',
    'Şans seninle 🍀',
    'Olumlu gelişme yakın ⭐',
  ];

  static const _oddMeanings = [
    'Dikkat, engel var ⚠️',
    'Bekle, henüz değil 🌙',
    'Hayır enerjisi var 🔴',
    'Sabır gerekiyor ⏳',
    'Yeniden düşün 🤔',
  ];

  static const _groupPositions = [
    'Kader',
    'Ev & Aile',
    'Aşk',
    'İş & Para',
    'Sağlık',
    'Yakın Gelecek',
    'Uzak Gelecek'
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _shakeAnimation = Tween<double>(begin: -5, end: 5).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut));
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _glowAnimation =
        Tween<double>(begin: 0.3, end: 1.0).animate(_glowController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _glowController.dispose();
    _intentController.dispose();
    super.dispose();
  }

  Future<void> _countBeans() async {
    setState(() => _counting = true);

    // Sallama animasyonu
    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      _shakeController.forward(from: 0);
    }

    // Geleneksel bakla falında 41 bakla sayılır
    // Rastgele 38-44 arası bir sayı seçilir (tek sayıya yakın)
    _totalBeans = 38 + _random.nextInt(7);

    // 7 gruba böl
    _groups = [];
    _isEven = [];
    int remaining = _totalBeans;

    for (int i = 0; i < 6; i++) {
      // Her grup 3-8 arası bakla
      final maxForGroup = remaining - (6 - i) * 3;
      final groupSize = 3 + _random.nextInt(maxForGroup.clamp(1, 6));
      _groups.add(groupSize);
      _isEven.add(groupSize % 2 == 0);
      remaining -= groupSize;
    }
    _groups.add(remaining);
    _isEven.add(remaining % 2 == 0);

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted)
      setState(() {
        _counting = false;
        _step = 2;
      });
  }

  Future<void> _getReading() async {
    setState(() => _loading = true);

    final groupDesc = List.generate(_groups.length, (i) {
      final count = _groups[i];
      final even = _isEven[i];
      final meaning = even
          ? _evenMeanings[_random.nextInt(_evenMeanings.length)]
          : _oddMeanings[_random.nextInt(_oddMeanings.length)];
      return '${_groupPositions[i]}: $count bakla (${even ? "Çift" : "Tek"}) - $meaning';
    }).join('\n');

    final evenCount = _isEven.where((e) => e).length;
    final oddCount = _isEven.where((e) => !e).length;

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
                  'Geleneksel Türk bakla falı yorumu yap. Niyet: "$_intent"\nToplam bakla: $_totalBeans\nÇift gruplar: $evenCount (olumlu), Tek gruplar: $oddCount (dikkat)\n\nGrupların analizi:\n$groupDesc\n\nBu bakla falını geleneksel Türk falcılığına uygun, mistik ve şiirsel şekilde yorumla. Çift sayıların olumlu, tek sayıların dikkat gerektiren enerjisini anlat. Türkçe, 6-7 cümle, emoji kullan, markdown kullanma.'
            }
          ],
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _result = data['content'][0]['text'] as String;
          _loading = false;
          _step = 3;
        });
      } else {
        setState(() {
          _result = 'Baklalar şu an sessiz... 🌙';
          _loading = false;
          _step = 3;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Evren şu an konuşmuyor... ✨';
        _loading = false;
        _step = 3;
      });
    }
  }

  void _reset() {
    setState(() {
      _step = 0;
      _intent = '';
      _groups = [];
      _isEven = [];
      _result = null;
      _totalBeans = 0;
    });
    _intentController.clear();
  }

  Widget _buildBeanGroup(int index) {
    final count = _groups[index];
    final even = _isEven[index];
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + index * 100),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: even
            ? const Color(0xFF1A3A1A).withOpacity(0.8)
            : const Color(0xFF3A1A1A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: even
                ? Colors.green.withOpacity(0.5)
                : Colors.red.withOpacity(0.3)),
      ),
      child: Row(children: [
        // Bakla görseli
        SizedBox(
          width: 80,
          child: Wrap(
            spacing: 3,
            runSpacing: 3,
            children: List.generate(
                count.clamp(0, 12),
                (_) => Container(
                      width: 10,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B6914),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 2)
                        ],
                      ),
                    )),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(_groupPositions[index],
                style: const TextStyle(
                    fontFamily: 'Cinzel', fontSize: 11, color: AppTheme.gold)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: even
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: even
                        ? Colors.green.withOpacity(0.5)
                        : Colors.red.withOpacity(0.5)),
              ),
              child: Text(even ? 'ÇİFT' : 'TEK',
                  style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 9,
                      color: even ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 4),
          Text('$count bakla',
              style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 12, color: AppTheme.white)),
          const SizedBox(height: 2),
          Text(
            even
                ? _evenMeanings[index % _evenMeanings.length]
                : _oddMeanings[index % _oddMeanings.length],
            style: const TextStyle(
                fontFamily: 'Nunito', fontSize: 10, color: AppTheme.muted),
          ),
        ])),
      ]),
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
          child: const Text('🫘 Bakla Falı',
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
                          width: i == _step ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i <= _step
                                ? AppTheme.gold
                                : AppTheme.muted.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
              ),
              const SizedBox(height: 24),

              // ADIM 0: Niyet
              if (_step == 0) ...[
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) => Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF8B6914)
                                .withOpacity(0.4 * _glowAnimation.value),
                            blurRadius: 40,
                            spreadRadius: 10)
                      ],
                    ),
                    child: const Center(
                        child: Text('🫘', style: TextStyle(fontSize: 70))),
                  ),
                ),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.goldToLilac.createShader(bounds),
                  child: const Text('Bakla Falı',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 22,
                          color: Colors.white,
                          letterSpacing: 1)),
                ),
                const SizedBox(height: 8),
                const Text('Geleneksel Türk kehaneti',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AppTheme.gold.withOpacity(0.2))),
                  child: const Text(
                      '💡 Geleneksel bakla falında 41 bakla sayılır, tek/çift gruplara ayrılır. Her grup hayatın farklı alanlarını temsil eder.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          color: AppTheme.muted,
                          height: 1.5)),
                ),
                const SizedBox(height: 24),
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
                          'Niyetinizi veya sorunuzu yazın...\n(Ör: İş hayatım hakkında bilmek istiyorum)',
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

              // ADIM 1: Baklaları say
              if (_step == 1) ...[
                const Text(
                    '"Ellerinizi baklaların üzerine koyun,\nniyetinize odaklanın ve sayın..."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted,
                        height: 1.6)),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: _counting
                        ? Offset(_shakeAnimation.value, 0)
                        : Offset.zero,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A1A0A),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.gold.withOpacity(0.4), width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF8B6914).withOpacity(0.3),
                              blurRadius: 30)
                        ],
                      ),
                      child: Center(
                        child: _counting
                            ? const CircularProgressIndicator(
                                color: AppTheme.gold, strokeWidth: 2)
                            : Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                alignment: WrapAlignment.center,
                                children: List.generate(
                                    21,
                                    (_) => Container(
                                          width: 12,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8B6914),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                        )),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_counting) ...[
                  const Text('Baklalar sayılıyor...',
                      style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.muted)),
                ] else ...[
                  GestureDetector(
                    onTap: _countBeans,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFB8860B), Color(0xFF8B4914)]),
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF8B6914).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: const Center(
                          child: Text('🫘 Baklaları Say',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 1))),
                    ),
                  ),
                ],
              ],

              // ADIM 2: Gruplar
              if (_step == 2 && _groups.isNotEmpty) ...[
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: AppTheme.purple1.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppTheme.gold.withOpacity(0.3))),
                    child: Text('Toplam: $_totalBeans bakla',
                        style: const TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 13,
                            color: AppTheme.gold)),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.3))),
                    child: Text('${_isEven.where((e) => e).length} çift',
                        style: const TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 11,
                            color: Colors.green)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3))),
                    child: Text('${_isEven.where((e) => !e).length} tek',
                        style: const TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 11,
                            color: Colors.red)),
                  ),
                ]),
                const SizedBox(height: 20),
                ...List.generate(_groups.length, (i) => _buildBeanGroup(i)),
                const SizedBox(height: 16),
                if (_loading) ...[
                  const CircularProgressIndicator(
                      color: AppTheme.gold, strokeWidth: 2),
                  const SizedBox(height: 12),
                  const Text('Baklalar yorumlanıyor... 🫘✨',
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
                            colors: [AppTheme.gold, AppTheme.violet]),
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.violet.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: const Center(
                          child: Text('🔮 Yorumu Gör',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 1))),
                    ),
                  ),
                ],
              ],

              // ADIM 3: Yorum
              if (_step == 3 && _result != null) ...[
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: AppTheme.purple1.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppTheme.gold.withOpacity(0.3))),
                    child: Text(
                        '$_totalBeans bakla • ${_isEven.where((e) => e).length} çift • ${_isEven.where((e) => !e).length} tek',
                        style: const TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 11,
                            color: AppTheme.gold)),
                  ),
                ]),
                const SizedBox(height: 16),
                ...List.generate(_groups.length, (i) => _buildBeanGroup(i)),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      const Color(0xFF2A1A0A).withOpacity(0.8),
                      AppTheme.purple1.withOpacity(0.6)
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
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
                        fortuneType: 'Bakla Falı',
                        fortuneEmoji: '🫘',
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
                        fortuneType: 'Bakla Falı',
                        fortuneEmoji: '🫘',
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
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
