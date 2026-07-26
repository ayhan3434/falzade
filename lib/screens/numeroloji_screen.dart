import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class NumerologiScreen extends StatefulWidget {
  const NumerologiScreen({super.key});

  @override
  State<NumerologiScreen> createState() => _NumerologiScreenState();
}

class _NumerologiScreenState extends State<NumerologiScreen> {
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  bool _loading = false;
  String? _result;
  Map<String, dynamic>? _numbers;

  static const _letterValues = {
    'A': 1,
    'B': 2,
    'C': 3,
    'D': 4,
    'E': 5,
    'F': 6,
    'G': 7,
    'H': 8,
    'I': 9,
    'J': 1,
    'K': 2,
    'L': 3,
    'M': 4,
    'N': 5,
    'O': 6,
    'P': 7,
    'Q': 8,
    'R': 9,
    'S': 1,
    'T': 2,
    'U': 3,
    'V': 4,
    'W': 5,
    'X': 6,
    'Y': 7,
    'Z': 8,
    'Ç': 3,
    'Ğ': 7,
    'İ': 9,
    'Ö': 6,
    'Ş': 1,
    'Ü': 3,
  };

  int _reduceNumber(int n) {
    while (n > 9 && n != 11 && n != 22 && n != 33) {
      n = n.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    return n;
  }

  Map<String, dynamic> _calculateNumbers(String name, String birthDate) {
    final digits = birthDate.replaceAll(RegExp(r'[^0-9]'), '');
    final lifePathSum = digits.split('').map(int.parse).reduce((a, b) => a + b);
    final lifePath = _reduceNumber(lifePathSum);

    final nameUpper = name.toUpperCase().replaceAll(' ', '');
    int nameSum = 0;
    for (final char in nameUpper.split('')) {
      nameSum += _letterValues[char] ?? 0;
    }
    final nameNumber = _reduceNumber(nameSum);

    const vowels = {'A', 'E', 'I', 'İ', 'O', 'Ö', 'U', 'Ü'};
    int soulSum = 0;
    for (final char in nameUpper.split('')) {
      if (vowels.contains(char)) soulSum += _letterValues[char] ?? 0;
    }
    final soulNumber = _reduceNumber(soulSum);

    int personalitySum = 0;
    for (final char in nameUpper.split('')) {
      if (!vowels.contains(char) && _letterValues.containsKey(char)) {
        personalitySum += _letterValues[char] ?? 0;
      }
    }
    final personalityNumber = _reduceNumber(personalitySum);

    return {
      'lifePath': lifePath,
      'nameNumber': nameNumber,
      'soulNumber': soulNumber,
      'personalityNumber': personalityNumber,
    };
  }

  static const _numberMeanings = {
    1: 'Liderlik, bağımsızlık ve özgünlük',
    2: 'Uyum, ortaklık ve denge',
    3: 'Yaratıcılık, ifade ve şans',
    4: 'İstikrar, disiplin ve çalışkanlık',
    5: 'Özgürlük, değişim ve macera',
    6: 'Sorumluluk, sevgi ve şifa',
    7: 'Bilgelik, mistisizm ve ruhsallık',
    8: 'Güç, başarı ve bolluk',
    9: 'İnsanlık, tamamlanma ve evrensel sevgi',
    11: 'Sezgi, ilham ve ruhsal uyanış (Usta Sayı)',
    22: 'Büyük inşaatçı, hayalleri gerçekleştirme (Usta Sayı)',
    33: 'Usta öğretmen, şefkat ve ilham (Usta Sayı)',
  };

  Future<void> _calculate() async {
    final name = _nameController.text.trim();
    final date = _dateController.text.trim();

    if (name.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen isim ve doğum tarihini girin'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    final numbers = _calculateNumbers(name, date);
    setState(() {
      _numbers = numbers;
      _loading = true;
      _result = null;
    });

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
                  'Numeroloji falı yorumu yap. İsim: $name, Doğum Tarihi: $date\n\nHesaplanan sayılar:\n- Yaşam Yolu Sayısı: ${numbers['lifePath']} (${_numberMeanings[numbers['lifePath']]})\n- İsim Sayısı: ${numbers['nameNumber']} (${_numberMeanings[numbers['nameNumber']]})\n- Ruh Sayısı: ${numbers['soulNumber']} (${_numberMeanings[numbers['soulNumber']]})\n- Kişilik Sayısı: ${numbers['personalityNumber']} (${_numberMeanings[numbers['personalityNumber']]})\n\nBu sayıları mistik ve şiirsel şekilde yorumla. Kişinin karakteri, kaderi ve geleceği hakkında detaylı yorum yap. Türkçe, 5-6 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Sayılar şu an sessiz... 🔢';
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
      _numbers = null;
      _result = null;
    });
    _nameController.clear();
    _dateController.clear();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
                primary: AppTheme.gold, surface: AppTheme.purple1)),
        child: child!,
      ),
    );
    if (picked != null) {
      _dateController.text =
          '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Widget _buildSingleCard(Map<String, dynamic> card) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.purple1.withOpacity(0.8),
            AppTheme.purple2.withOpacity(0.6)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(card['emoji'] as String, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text('${card['number']}',
              style: const TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 22,
                  color: AppTheme.gold,
                  fontWeight: FontWeight.bold)),
          Text(card['label'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 10, color: AppTheme.muted)),
        ],
      ),
    );
  }

  Widget _buildNumberCards() {
    final cards = [
      {'label': 'Yaşam Yolu', 'number': _numbers!['lifePath'], 'emoji': '🛤️'},
      {'label': 'İsim Sayısı', 'number': _numbers!['nameNumber'], 'emoji': '✨'},
      {'label': 'Ruh Sayısı', 'number': _numbers!['soulNumber'], 'emoji': '💫'},
      {
        'label': 'Kişilik',
        'number': _numbers!['personalityNumber'],
        'emoji': '🌟'
      },
    ];

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildSingleCard(cards[0]),
              const SizedBox(height: 10),
              _buildSingleCard(cards[2]),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              _buildSingleCard(cards[1]),
              const SizedBox(height: 10),
              _buildSingleCard(cards[3]),
            ],
          ),
        ),
      ],
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
          child: const Text('🔢 Numeroloji',
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
              const Text('Sayıların Gizemi',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 32),
              const Text('🔢', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              const Text('"Her sayı bir kaderi taşır..."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 32),
              if (_result == null) ...[
                Container(
                  decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppTheme.purple3.withOpacity(0.4))),
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(
                        color: AppTheme.white, fontFamily: 'Nunito'),
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Tam adınız (Ad Soyad)',
                      hintStyle: TextStyle(color: AppTheme.muted, fontSize: 13),
                      prefixIcon: Icon(Icons.person_outline,
                          color: AppTheme.gold, size: 20),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppTheme.purple1.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.purple3.withOpacity(0.4))),
                    child: TextField(
                      controller: _dateController,
                      enabled: false,
                      style: const TextStyle(
                          color: AppTheme.white, fontFamily: 'Nunito'),
                      decoration: const InputDecoration(
                        hintText: 'Doğum tarihiniz',
                        hintStyle:
                            TextStyle(color: AppTheme.muted, fontSize: 13),
                        prefixIcon: Icon(Icons.calendar_today_outlined,
                            color: AppTheme.gold, size: 20),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_loading) ...[
                  if (_numbers != null) _buildNumberCards(),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                      color: AppTheme.gold, strokeWidth: 2),
                  const SizedBox(height: 12),
                  const Text('Sayılar hesaplanıyor... 🔢✨',
                      style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.muted)),
                ] else ...[
                  GestureDetector(
                    onTap: _calculate,
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
                          child: Text('🔢 Sayılarımı Hesapla',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 15,
                                  color: Colors.white,
                                  letterSpacing: 1))),
                    ),
                  ),
                ],
              ] else ...[
                if (_numbers != null) _buildNumberCards(),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppTheme.purple3.withOpacity(0.4))),
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
                        fortuneType: 'Numeroloji',
                        fortuneEmoji: '🔢',
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
                        fortuneType: 'Numeroloji',
                        fortuneEmoji: '🔢',
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
                          border:
                              Border.all(color: AppTheme.gold.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(25)),
                      child: const Center(
                          child: Text('🔄 Yeni Hesaplama',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.gold,
                                  fontFamily: 'Nunito')))),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
