import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';
import 'package:falcim/services/language_service.dart';
import 'package:provider/provider.dart';

class MumScreen extends StatefulWidget {
  const MumScreen({super.key});
  @override
  State<MumScreen> createState() => _MumScreenState();
}

class _MumScreenState extends State<MumScreen> with TickerProviderStateMixin {
  final _picker = ImagePicker();
  File? _image;
  bool _loading = false;
  String? _result;

  late AnimationController _flameController;
  late Animation<double> _flameAnimation;
  late AnimationController _flickerController;
  late Animation<double> _flickerAnimation;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _flameAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _flameController, curve: Curves.easeInOut));
    _flickerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..repeat(reverse: true);
    _flickerAnimation =
        Tween<double>(begin: 0.95, end: 1.05).animate(_flickerController);
  }

  @override
  void dispose() {
    _flameController.dispose();
    _flickerController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1024);
    if (picked == null) return;
    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final isValid = await _checkIfCandle(bytes);
    if (!isValid) {
      if (mounted)
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                    backgroundColor: AppTheme.purple1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: const Text('Mum Görünmüyor 🕯️',
                        style: TextStyle(
                            fontFamily: 'Cinzel',
                            color: AppTheme.gold,
                            fontSize: 15)),
                    content: const Text(
                        'Yüklediğin resimde yanan bir mum görünmüyor. Lütfen yanan mumun fotoğrafını çek.',
                        style: TextStyle(
                            color: AppTheme.muted,
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            height: 1.5)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tamam',
                              style: TextStyle(color: AppTheme.gold)))
                    ]));
      return;
    }
    setState(() {
      _image = file;
      _result = null;
    });
    await _analyzeCandle(bytes);
  }

  Future<bool> _checkIfCandle(List<int> bytes) async {
    try {
      final base64Image = base64Encode(bytes);
      final response =
          await http.post(Uri.parse('https://api.anthropic.com/v1/messages'),
              headers: {
                'Content-Type': 'application/json',
                'x-api-key': AppConstants.claudeApiKey,
                'anthropic-version': '2023-06-01'
              },
              body: jsonEncode({
                'model': 'claude-haiku-4-5-20251001',
                'max_tokens': 10,
                'messages': [
                  {
                    'role': 'user',
                    'content': [
                      {
                        'type': 'image',
                        'source': {
                          'type': 'base64',
                          'media_type': 'image/jpeg',
                          'data': base64Image
                        }
                      },
                      {
                        'type': 'text',
                        'text':
                            'Is there a candle (burning or with wax) in this image? Answer only YES or NO.'
                      }
                    ]
                  }
                ]
              }));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return (data['content'][0]['text'] as String)
            .toUpperCase()
            .contains('YES');
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  Future<void> _analyzeCandle(List<int> bytes) async {
    setState(() => _loading = true);
    final langName = context.read<LanguageService>().languageName;
    try {
      final base64Image = base64Encode(bytes);
      final response =
          await http.post(Uri.parse('https://api.anthropic.com/v1/messages'),
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
                    'content': [
                      {
                        'type': 'image',
                        'source': {
                          'type': 'base64',
                          'media_type': 'image/jpeg',
                          'data': base64Image
                        }
                      },
                      {
                        'type': 'text',
                        'text':
                            'Look at this candle photo and give a mystical candle fortune reading. Interpret the flame shape, candle color, wax drippings and their patterns. Write in $langName. 5-6 sentences, use emojis, no markdown, plain text only.'
                      }
                    ]
                  }
                ]
              }));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _result = data['content'][0]['text'] as String;
          _loading = false;
        });
      } else {
        setState(() {
          _result = 'Alev şu an titremiyor... 🕯️';
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

  void _showPickOptions() {
    showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.purple1,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.muted,
                      borderRadius: BorderRadius.circular(2))),
              ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppTheme.white),
                  title: const Text('Fotoğraf Çek',
                      style: TextStyle(color: AppTheme.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  }),
              ListTile(
                  leading:
                      const Icon(Icons.photo_library, color: AppTheme.white),
                  title: const Text('Galeriden Seç',
                      style: TextStyle(color: AppTheme.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  }),
              const SizedBox(height: 20),
            ]));
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
            child: const Text('🕯️ Mum Falı',
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
            const Text('Mumun Alevini Fotoğrafla',
                style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted)),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: Listenable.merge([_flameAnimation, _flickerAnimation]),
              builder: (context, child) =>
                  Stack(alignment: Alignment.center, children: [
                Container(
                    width: 120,
                    height: 120,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, boxShadow: [
                      BoxShadow(
                          color: const Color(0xFFFF6F00)
                              .withOpacity(0.4 * _flameAnimation.value),
                          blurRadius: 50,
                          spreadRadius: 15),
                      BoxShadow(
                          color: const Color(0xFFFFD600)
                              .withOpacity(0.2 * _flickerAnimation.value),
                          blurRadius: 70,
                          spreadRadius: 25),
                    ])),
                Transform.scale(
                    scale: _flameAnimation.value,
                    child: const Text('🕯️', style: TextStyle(fontSize: 80))),
              ]),
            ),
            const SizedBox(height: 16),
            const Text('"Alevin dili vardır, dinlemesini bilene..."',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted,
                    height: 1.5)),
            const SizedBox(height: 24),
            if (_image == null && !_loading) ...[
              Row(children: [
                Expanded(
                    child: GestureDetector(
                        onTap: () => _pickImage(ImageSource.camera),
                        child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                                color: AppTheme.purple1.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppTheme.gold.withOpacity(0.4))),
                            child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('📸', style: TextStyle(fontSize: 32)),
                                  SizedBox(height: 8),
                                  Text('Fotoğraf Çek',
                                      style: TextStyle(
                                          fontFamily: 'Cinzel',
                                          fontSize: 11,
                                          color: AppTheme.white))
                                ])))),
                const SizedBox(width: 12),
                Expanded(
                    child: GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                                color: AppTheme.purple1.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppTheme.violet.withOpacity(0.4))),
                            child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('🖼️', style: TextStyle(fontSize: 32)),
                                  SizedBox(height: 8),
                                  Text('Galeriden Seç',
                                      style: TextStyle(
                                          fontFamily: 'Cinzel',
                                          fontSize: 11,
                                          color: AppTheme.white))
                                ])))),
              ]),
              const SizedBox(height: 16),
              Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AppTheme.gold.withOpacity(0.2))),
                  child: const Text(
                      '💡 Yanan mumunuzun net bir fotoğrafını çekin. Alevin şekli, mumun rengi ve mum eriğinin desenleri yorumlanacak.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          color: AppTheme.muted,
                          height: 1.5))),
            ],
            if (_loading) ...[
              if (_image != null)
                ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_image!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover)),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                  color: AppTheme.gold, strokeWidth: 2),
              const SizedBox(height: 16),
              const Text('Alev okunuyor... 🕯️✨',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
            ],
            if (_result != null && !_loading) ...[
              ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_image!,
                      height: 200, width: double.infinity, fit: BoxFit.cover)),
              const SizedBox(height: 20),
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        const Color(0xFFE65100).withOpacity(0.08),
                        AppTheme.purple1.withOpacity(0.6)
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFFF6F00).withOpacity(0.2))),
                  child: Text(_result!,
                      style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                          height: 1.8))),
              const SizedBox(height: 20),
              const Text('Bu yorumu paylaşmak ister misin?',
                  style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 13,
                      color: AppTheme.gold)),
              const SizedBox(height: 16),
              _shareBtn(context, '✦ Akışta ve Profilde Paylaş', true),
              const SizedBox(height: 10),
              _shareBtn(context, 'Sadece Profilimde Paylaş', false),
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
                  onTap: () => setState(() {
                        _image = null;
                        _result = null;
                      }),
                  child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: AppTheme.gold.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(25)),
                      child: const Center(
                          child: Text('🔄 Yeni Fotoğraf',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.gold,
                                  fontFamily: 'Nunito'))))),
              const SizedBox(height: 20),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _shareBtn(BuildContext context, String label, bool toFeed) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        final ps = PostService();
        await ps.createPost(
            caption:
                '"${_result!.substring(0, _result!.length > 80 ? 80 : _result!.length)}..."',
            fortuneType: 'Mum Falı',
            fortuneEmoji: '🕯️',
            fortuneResult: _result!,
            shareToFeed: toFeed,
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
              gradient: toFeed
                  ? const LinearGradient(
                      colors: [AppTheme.violet, AppTheme.purple3])
                  : null,
              border: toFeed
                  ? null
                  : Border.all(color: AppTheme.violet.withOpacity(0.6)),
              borderRadius: BorderRadius.circular(25)),
          child: Center(
              child: Text(label,
                  style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 13,
                      color: toFeed ? Colors.white : AppTheme.white,
                      letterSpacing: 1)))),
    );
  }
}
