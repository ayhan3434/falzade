import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class DruidScreen extends StatefulWidget {
  const DruidScreen({super.key});
  @override
  State<DruidScreen> createState() => _DruidScreenState();
}

class _DruidScreenState extends State<DruidScreen>
    with TickerProviderStateMixin {
  final _intentController = TextEditingController();
  String _intent = '';
  bool _loading = false;
  String? _result;
  Map<String, dynamic>? _reading;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  static const _agaclar = [
    {
      'ad': 'Meşe',
      'emoji': '🌳',
      'anlam': 'Güç, dayanıklılık ve bilgelik',
      'color': 0xFF4E342E
    },
    {
      'ad': 'Huş',
      'emoji': '🌲',
      'anlam': 'Yeni başlangıçlar ve arınma',
      'color': 0xFF2E7D32
    },
    {
      'ad': 'Karaağaç',
      'emoji': '🌴',
      'anlam': 'Dönüşüm ve değişim',
      'color': 0xFF1B5E20
    },
    {
      'ad': 'Elma',
      'emoji': '🍎',
      'anlam': 'Aşk, güzellik ve ebedi yaşam',
      'color': 0xFFB71C1C
    },
    {
      'ad': 'Yew',
      'emoji': '🌿',
      'anlam': 'Ölüm ve yeniden doğuş',
      'color': 0xFF1A237E
    },
    {
      'ad': 'Dişbudak',
      'emoji': '🎋',
      'anlam': 'Dünya ağacı, bağlantı',
      'color': 0xFF33691E
    },
  ];

  static const _keltMevsimleri = [
    {
      'mevsim': 'Samhain',
      'emoji': '🎃',
      'anlam': 'Ölüler günü, perdenin incelmesi'
    },
    {
      'mevsim': 'Imbolc',
      'emoji': '🕯️',
      'anlam': 'Baharın ilk ışıkları, yenilenme'
    },
    {'mevsim': 'Beltane', 'emoji': '🔥', 'anlam': 'Ateş festivali, bereket'},
    {'mevsim': 'Lughnasadh', 'emoji': '🌾', 'anlam': 'Hasat festivali, bolluk'},
  ];

  static const _oghamHarfleri = [
    'ᚁ',
    'ᚂ',
    'ᚃ',
    'ᚄ',
    'ᚅ',
    'ᚆ',
    'ᚇ',
    'ᚈ',
    'ᚉ',
    'ᚊ'
  ];

  void _generateReading() {
    final random = Random();
    final now = DateTime.now();
    final mevsimIndex = (now.month - 1) ~/ 3;
    _reading = {
      'agac': _agaclar[random.nextInt(_agaclar.length)],
      'mevsim': _keltMevsimleri[mevsimIndex % 4],
      'ogham': _oghamHarfleri[random.nextInt(_oghamHarfleri.length)],
      'yon': ['Kuzey', 'Güney', 'Doğu', 'Batı'][random.nextInt(4)],
    };
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
        AnimationController(vsync: this, duration: const Duration(seconds: 15))
          ..repeat();
    _rotateAnimation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_rotateController);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _rotateController.dispose();
    _intentController.dispose();
    super.dispose();
  }

  Future<void> _getReading() async {
    if (_intent.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lütfen niyetinizi yazın'),
          backgroundColor: Colors.redAccent));
      return;
    }
    _generateReading();
    setState(() => _loading = true);

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
                  'Antik Kelt Druid geleneğine göre kehanet yap.\n\nNiyet: $_intent\nKutsal Ağaç: ${_reading!['agac']['ad']} ${_reading!['agac']['emoji']} - ${_reading!['agac']['anlam']}\nKelt Mevsimi: ${_reading!['mevsim']['mevsim']} ${_reading!['mevsim']['emoji']} - ${_reading!['mevsim']['anlam']}\nOgham Harfi: ${_reading!['ogham']}\nKutsal Yön: ${_reading!['yon']}\n\nDruid geleneğinin kutsal ağaç bilgeliğini, Ogham alfabesini ve Kelt mevsim enerjisini niyetle ilişkilendirerek mistik bir kehanet yap. Doğanın sesini ve ruhların mesajını ilet. Türkçe, 6-7 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Orman şu an sessiz... 🌳';
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
      _intent = '';
      _result = null;
      _reading = null;
    });
    _intentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final agacColor = _reading != null
        ? Color(_reading!['agac']['color'] as int)
        : const Color(0xFF2E7D32);

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
            shaderCallback: (bounds) =>
                AppTheme.goldToLilac.createShader(bounds),
            child: const Text('🌙 Druid Falı',
                style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1))),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Text('Antik Kelt Kehaneti',
                style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted)),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: Listenable.merge([_glowAnimation, _rotateAnimation]),
              builder: (context, child) =>
                  Stack(alignment: Alignment.center, children: [
                Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: agacColor
                                    .withOpacity(0.2 * _glowAnimation.value),
                                width: 1)))),
                Transform.rotate(
                    angle: -_rotateAnimation.value * 0.4,
                    child: Container(
                        width: 115,
                        height: 115,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF4E342E)
                                    .withOpacity(0.2 * _glowAnimation.value),
                                width: 1)))),
                Container(
                    width: 95,
                    height: 95,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, boxShadow: [
                      BoxShadow(
                          color:
                              agacColor.withOpacity(0.3 * _glowAnimation.value),
                          blurRadius: 40,
                          spreadRadius: 15)
                    ]),
                    child: Center(
                        child: Text(
                            _reading != null
                                ? _reading!['agac']['emoji'] as String
                                : '🌙',
                            style: const TextStyle(fontSize: 60)))),
              ]),
            ),
            const SizedBox(height: 16),
            const Text('"Ağaçlar konuşur, Druidler dinler..."',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted,
                    height: 1.5)),
            const SizedBox(height: 24),
            if (_result == null) ...[
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
                        'Niyetinizi yazın...\n(Doğanın ruhlarına ne sormak istiyorsunuz?)',
                    hintStyle: TextStyle(
                        color: AppTheme.muted, fontSize: 12, height: 1.5),
                    prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child:
                            Icon(Icons.forest, color: AppTheme.gold, size: 20)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_loading) ...[
                const CircularProgressIndicator(
                    color: AppTheme.gold, strokeWidth: 2),
                const SizedBox(height: 12),
                const Text('Ağaçlar fısıldıyor... 🌳✨',
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
              ] else
                GestureDetector(
                    onTap: _getReading,
                    child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFF1B5E20), Color(0xFF4E342E)]),
                            borderRadius: BorderRadius.circular(27),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      const Color(0xFF2E7D32).withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5))
                            ]),
                        child: const Center(
                            child: Text('🌳 Ormanı Dinle',
                                style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 15,
                                    color: Colors.white,
                                    letterSpacing: 1))))),
            ] else ...[
              if (_reading != null) ...[
                Row(children: [
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: agacColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: agacColor.withOpacity(0.3))),
                    child: Column(children: [
                      Text(_reading!['agac']['emoji'] as String,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      const Text('Kutsal Ağaç',
                          style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 8,
                              color: AppTheme.muted)),
                      Text(_reading!['agac']['ad'] as String,
                          style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 12,
                              color: agacColor,
                              fontWeight: FontWeight.bold)),
                      Text(_reading!['agac']['anlam'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 8,
                              color: AppTheme.muted)),
                    ]),
                  )),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppTheme.purple1.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppTheme.gold.withOpacity(0.2))),
                    child: Column(children: [
                      Text(_reading!['mevsim']['emoji'] as String,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      const Text('Kelt Mevsimi',
                          style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 8,
                              color: AppTheme.muted)),
                      Text(_reading!['mevsim']['mevsim'] as String,
                          style: const TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 11,
                              color: AppTheme.gold,
                              fontWeight: FontWeight.bold)),
                      Text(_reading!['mevsim']['anlam'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 8,
                              color: AppTheme.muted)),
                    ]),
                  )),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppTheme.gold.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppTheme.gold.withOpacity(0.3))),
                    child: Column(children: [
                      Text(_reading!['ogham'] as String,
                          style: const TextStyle(
                              fontSize: 32,
                              color: AppTheme.gold,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Ogham',
                          style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 8,
                              color: AppTheme.muted)),
                      Text('${_reading!['yon']} Yönü',
                          style: const TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 10,
                              color: AppTheme.gold)),
                    ]),
                  )),
                ]),
                const SizedBox(height: 16),
              ],
              _buildResultSection(_result!, 'Druid Falı', '🌙'),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _buildResultSection(String result, String fortuneType, String emoji) {
    return Column(children: [
      Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFF1B5E20).withOpacity(0.1),
                AppTheme.purple1.withOpacity(0.6)
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2))),
          child: Text(result,
              style: const TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                  height: 1.8))),
      const SizedBox(height: 24),
      const Text('Bu yorumu paylaşmak ister misin?',
          style: TextStyle(
              fontFamily: 'Cinzel', fontSize: 13, color: AppTheme.gold)),
      const SizedBox(height: 12),
      GestureDetector(
          onTap: () async {
            final ps = PostService();
            await ps.createPost(
                caption:
                    '"${result.substring(0, result.length > 80 ? 80 : result.length)}..."',
                fortuneType: fortuneType,
                fortuneEmoji: emoji,
                fortuneResult: result,
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
                          letterSpacing: 1))))),
      const SizedBox(height: 10),
      GestureDetector(
          onTap: () async {
            final ps = PostService();
            await ps.createPost(
                caption:
                    '"${result.substring(0, result.length > 80 ? 80 : result.length)}..."',
                fortuneType: fortuneType,
                fortuneEmoji: emoji,
                fortuneResult: result,
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
                  border: Border.all(color: AppTheme.violet.withOpacity(0.6)),
                  borderRadius: BorderRadius.circular(25)),
              child: const Center(
                  child: Text('Sadece Profilimde Paylaş',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 13,
                          color: AppTheme.white,
                          letterSpacing: 1))))),
      const SizedBox(height: 10),
      GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.muted.withOpacity(0.3)),
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
                  border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(25)),
              child: const Center(
                  child: Text('🔄 Yeni Fal',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.gold,
                          fontFamily: 'Nunito'))))),
      const SizedBox(height: 20),
    ]);
  }
}
