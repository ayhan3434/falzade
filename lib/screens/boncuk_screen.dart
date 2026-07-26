import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class BoncukScreen extends StatefulWidget {
  const BoncukScreen({super.key});
  @override
  State<BoncukScreen> createState() => _BoncukScreenState();
}

class _BoncukScreenState extends State<BoncukScreen>
    with TickerProviderStateMixin {
  final _intentController = TextEditingController();
  String _intent = '';
  bool _loading = false;
  String? _result;
  List<Map<String, dynamic>> _secilenBoncuklar = [];

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  static const _boncukRenkleri = [
    {'renk': 'Mavi', 'anlam': 'Koruma ve huzur', 'color': 0xFF1565C0},
    {'renk': 'Yeşil', 'anlam': 'Şifa ve büyüme', 'color': 0xFF2E7D32},
    {'renk': 'Kırmızı', 'anlam': 'Güç ve tutku', 'color': 0xFFB71C1C},
    {'renk': 'Mor', 'anlam': 'Ruhsallık ve sezgi', 'color': 0xFF6A1B9A},
    {'renk': 'Altın', 'anlam': 'Bolluk ve bereket', 'color': 0xFFFF8F00},
    {'renk': 'Beyaz', 'anlam': 'Arınma ve saflık', 'color': 0xFF90A4AE},
  ];

  @override
  void initState() {
    super.initState();
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _glowAnimation =
        Tween<double>(begin: 0.4, end: 1.0).animate(_glowController);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _intentController.dispose();
    super.dispose();
  }

  void _boncukSec(Map<String, dynamic> boncuk) {
    if (_secilenBoncuklar.length >= 7) return;
    setState(() => _secilenBoncuklar.add(boncuk));
  }

  void _boncukKaldir(int index) {
    setState(() => _secilenBoncuklar.removeAt(index));
  }

  Future<void> _getReading() async {
    if (_intent.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lütfen niyetinizi yazın'),
          backgroundColor: Colors.redAccent));
      return;
    }
    if (_secilenBoncuklar.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Lütfen 7 boncuk seçin (${_secilenBoncuklar.length}/7)'),
          backgroundColor: Colors.redAccent));
      return;
    }
    setState(() => _loading = true);

    final boncukListesi =
        _secilenBoncuklar.map((b) => '${b['renk']} (${b['anlam']})').join(', ');

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
                  'Boncuk (tespih) falı yorumu yap.\n\nNiyet: $_intent\nSeçilen 7 Boncuk (sırasıyla): $boncukListesi\n\nBoncukların renklerini, sıralamasını ve niyetle ilişkisini yorumla. Her rengin enerjisinin niyete nasıl etki ettiğini mistik ve şiirsel bir dille anlat. Türkçe, 5-6 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Boncuklar şu an sessiz... 📿';
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
      _secilenBoncuklar = [];
    });
    _intentController.clear();
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
            shaderCallback: (bounds) =>
                AppTheme.goldToLilac.createShader(bounds),
            child: const Text('📿 Boncuk Falı',
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
            const Text('7 Boncuk Seç, Niyetini Yaz',
                style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted)),
            const SizedBox(height: 24),

            // Boncuk seçim alanı
            if (_result == null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppTheme.purple1.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppTheme.purple3.withOpacity(0.4))),
                child: Column(children: [
                  const Text('Boncukları Seç',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 13,
                          color: AppTheme.gold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _boncukRenkleri.map((boncuk) {
                      final color = Color(boncuk['color'] as int);
                      return GestureDetector(
                        onTap: () => _boncukSec(boncuk),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _glowAnimation,
                              builder: (context, child) => Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color,
                                    boxShadow: [
                                      BoxShadow(
                                          color: color.withOpacity(
                                              0.4 * _glowAnimation.value),
                                          blurRadius: 12,
                                          spreadRadius: 2)
                                    ]),
                                child: const Center(
                                    child: Text('📿',
                                        style: TextStyle(fontSize: 22))),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(boncuk['renk'] as String,
                                style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 9,
                                    color: AppTheme.muted)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // Seçilen boncuklar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppTheme.purple1.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _secilenBoncuklar.length == 7
                            ? AppTheme.gold.withOpacity(0.6)
                            : AppTheme.purple3.withOpacity(0.4))),
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Seçilen Boncuklar',
                            style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 13,
                                color: AppTheme.gold)),
                        Text('${_secilenBoncuklar.length}/7',
                            style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 13,
                                color: _secilenBoncuklar.length == 7
                                    ? AppTheme.gold
                                    : AppTheme.muted)),
                      ]),
                  const SizedBox(height: 12),
                  _secilenBoncuklar.isEmpty
                      ? const Text('Yukarıdan boncuk seçin',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              color: AppTheme.muted))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _secilenBoncuklar.asMap().entries.map((entry) {
                            final color = Color(entry.value['color'] as int);
                            return GestureDetector(
                              onTap: () => _boncukKaldir(entry.key),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                    color: color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: color.withOpacity(0.6))),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: color)),
                                      const SizedBox(width: 4),
                                      Text(entry.value['renk'] as String,
                                          style: const TextStyle(
                                              fontFamily: 'Nunito',
                                              fontSize: 10,
                                              color: AppTheme.white)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.close,
                                          size: 10, color: AppTheme.muted),
                                    ]),
                              ),
                            );
                          }).toList(),
                        ),
                ]),
              ),
              const SizedBox(height: 16),

              // Niyet yazma
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
                        'Niyetinizi yazın...\n(Boncuklara ne sormak istiyorsunuz?)',
                    hintStyle: TextStyle(
                        color: AppTheme.muted, fontSize: 12, height: 1.5),
                    prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(Icons.blur_circular,
                            color: AppTheme.gold, size: 20)),
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
                const Text('Boncuklar okunuyor... 📿✨',
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
                            gradient: LinearGradient(colors: [
                              _secilenBoncuklar.length == 7
                                  ? const Color(0xFF4A148C)
                                  : AppTheme.muted,
                              _secilenBoncuklar.length == 7
                                  ? AppTheme.violet
                                  : AppTheme.muted
                            ]),
                            borderRadius: BorderRadius.circular(27),
                            boxShadow: [
                              BoxShadow(
                                  color: AppTheme.violet.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5))
                            ]),
                        child: Center(
                            child: Text(
                                _secilenBoncuklar.length == 7
                                    ? '📿 Boncukları Çevir'
                                    : '📿 ${_secilenBoncuklar.length}/7 Boncuk Seçildi',
                                style: const TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 15,
                                    color: Colors.white,
                                    letterSpacing: 1))))),
            ] else ...[
              // Seçilen boncukları göster
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _secilenBoncuklar.map((b) {
                  final color = Color(b['color'] as int);
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        boxShadow: [
                          BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1)
                        ]),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _buildResultSection(_result!, 'Boncuk Falı', '📿'),
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
                const Color(0xFF4A148C).withOpacity(0.1),
                AppTheme.purple1.withOpacity(0.6)
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.violet.withOpacity(0.2))),
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
                  child: Text('❤ Akışta ve Profilde Paylaş',
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
