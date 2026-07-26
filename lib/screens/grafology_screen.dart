import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class GrafologyScreen extends StatefulWidget {
  const GrafologyScreen({super.key});

  @override
  State<GrafologyScreen> createState() => _GrafologyScreenState();
}

class _GrafologyScreenState extends State<GrafologyScreen> {
  final _picker = ImagePicker();
  File? _image;
  bool _loading = false;
  String? _result;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1024);
    if (picked == null) return;
    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final isValid = await _checkIfHandwriting(bytes);
    if (!isValid) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.purple1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Yazı Görünmüyor ✍️',
                style: TextStyle(
                    fontFamily: 'Cinzel', color: AppTheme.gold, fontSize: 15)),
            content: const Text(
                'Yüklediğin resimde el yazısı görünmüyor. Lütfen el yazınızın net göründüğü bir fotoğraf yükleyin.',
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
            ],
          ),
        );
      }
      return;
    }
    setState(() {
      _image = file;
      _result = null;
    });
    await _analyzeHandwriting(bytes);
  }

  Future<bool> _checkIfHandwriting(List<int> bytes) async {
    try {
      final base64Image = base64Encode(bytes);
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
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
                      'Bu resimde el yazısı veya yazı var mı? Sadece EVET veya HAYIR yaz.'
                }
              ]
            }
          ]
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return (data['content'][0]['text'] as String)
            .toUpperCase()
            .contains('EVET');
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  Future<void> _analyzeHandwriting(List<int> bytes) async {
    setState(() => _loading = true);
    try {
      final base64Image = base64Encode(bytes);
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
                      'Bu el yazısı fotoğrafına bakarak grafology (yazı bilimi) ve mistik bir fal yorumu yap. Yazının büyüklüğü, eğimi, baskısı, harflerin şekli ve boşlukları hakkında kişilik analizi ve geleceğe dair mistik yorum yap. Türkçe yaz, 5-6 cümle, emoji kullan, markdown kullanma, düz metin yaz.'
                },
              ]
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
          _result = 'Yazı şu an okunmuyor... 🌙';
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
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              leading: const Icon(Icons.photo_library, color: AppTheme.white),
              title: const Text('Galeriden Seç',
                  style: TextStyle(color: AppTheme.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              }),
          const SizedBox(height: 20),
        ],
      ),
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
          child: const Text('✍️ Grafology',
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
              const Text('El Yazısı Analizi',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 32),
              if (_image == null && !_loading) ...[
                const Text('✍️', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 24),
                const Text('"El yazın ruhunun aynasıdır..."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppTheme.gold.withOpacity(0.2))),
                  child: const Text(
                      '💡 İpucu: Bir kağıda birkaç satır el yazısıyla bir şeyler yazın. Net ve iyi aydınlatılmış bir ortamda fotoğraf çekin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: AppTheme.muted,
                          height: 1.5)),
                ),
                const SizedBox(height: 32),
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
                            ])),
                  )),
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
                            ])),
                  )),
                ]),
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
                const Text('Yazı analiz ediliyor... ✍️✨',
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
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover)),
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
                        fortuneType: 'Grafology',
                        fortuneEmoji: '✍️',
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
                        fortuneType: 'Grafology',
                        fortuneEmoji: '✍️',
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
                    onTap: () => setState(() {
                          _image = null;
                          _result = null;
                        }),
                    child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppTheme.gold.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(25)),
                        child: const Center(
                            child: Text('🔄 Yeni Yazı Yükle',
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
