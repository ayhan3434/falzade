import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/constants.dart';
import 'package:falcim/l10n/app_localizations.dart';
import 'package:falcim/services/language_service.dart';
import 'package:provider/provider.dart';

class ZuhreScreen extends StatefulWidget {
  const ZuhreScreen({super.key});
  @override
  State<ZuhreScreen> createState() => _ZuhreScreenState();
}

class _ZuhreScreenState extends State<ZuhreScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final l10n = AppLocalizations.of(context)!;
      _messages.add({
        'role': 'assistant',
        'content': l10n.starsConsulting,
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _loading) return;
    final languageService = context.read<LanguageService>();

    _messageController.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _loading = true;
    });
    _scrollToBottom();

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
          'max_tokens': 1024,
          'system':
              '''You are Zühre - a mystical and mysterious star fortune teller and spiritual guide.
You speak in ${languageService.languageName}. You interpret dreams, give mystical answers to love and relationship questions, make zodiac readings, and offer intuitive insights about the future.
Your speaking style: mystical, deep, poetic but warm and empathetic. You sometimes refer to stars, the universe, and fate.
Use emojis: 🔮✨⭐🌙🌟💫🌸
Keep answers concise, 3-5 sentences.''',
          'messages': _messages
              .where(
                  (m) => m['role'] != 'assistant' || _messages.indexOf(m) > 0)
              .map((m) => {'role': m['role'], 'content': m['content']})
              .toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final reply = data['content'][0]['text'] as String;
        setState(() {
          _messages.add({'role': 'assistant', 'content': reply});
          _loading = false;
        });
      } else {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _messages.add({'role': 'assistant', 'content': l10n.starsQuiet});
          _loading = false;
        });
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _messages.add({'role': 'assistant', 'content': l10n.universeQuiet});
        _loading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.deep,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(l10n),
          Expanded(child: _buildMessages(l10n)),
          _buildInput(l10n),
        ]),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
          color: AppTheme.purple1.withOpacity(0.5),
          border: Border(
              bottom: BorderSide(color: AppTheme.purple3.withOpacity(0.3)))),
      child: Row(children: [
        Container(
            width: 46,
            height: 46,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [AppTheme.gold, AppTheme.violet, AppTheme.rose])),
            child: Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppTheme.purple2),
                child: const Center(
                    child: Text('🔮', style: TextStyle(fontSize: 22))))),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.goldToLilac.createShader(bounds),
              child: const Text('Zühre',
                  style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1))),
          Text(l10n.starsConsulting,
              style: const TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.gold)),
        ]),
        const Spacer(),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.4))),
            child: Row(children: [
              Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.green)),
              const SizedBox(width: 4),
              const Text('Online',
                  style: TextStyle(
                      color: Colors.green, fontFamily: 'Nunito', fontSize: 11)),
            ])),
      ]),
    );
  }

  Widget _buildMessages(AppLocalizations l10n) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length + (_loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) return _buildTypingIndicator(l10n);
        final message = _messages[index];
        final isUser = message['role'] == 'user';
        return _buildMessageBubble(message['content'] ?? '', isUser);
      },
    );
  }

  Widget _buildMessageBubble(String message, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        colors: [AppTheme.purple2, AppTheme.violet])),
                child: const Center(
                    child: Text('🔮', style: TextStyle(fontSize: 16)))),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  gradient: isUser
                      ? const LinearGradient(
                          colors: [AppTheme.violet, AppTheme.purple3])
                      : null,
                  color: isUser ? null : AppTheme.purple1.withOpacity(0.8),
                  borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18)),
                  border: isUser
                      ? null
                      : Border.all(color: AppTheme.purple3.withOpacity(0.4))),
              child: Text(message,
                  style: TextStyle(
                      color: isUser ? Colors.white : AppTheme.white,
                      fontFamily: isUser ? 'Nunito' : 'Cormorant Garamond',
                      fontSize: isUser ? 14 : 15,
                      fontStyle: isUser ? FontStyle.normal : FontStyle.italic,
                      height: 1.5)),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [AppTheme.purple2, AppTheme.violet])),
            child: const Center(
                child: Text('🔮', style: TextStyle(fontSize: 16)))),
        const SizedBox(width: 8),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: AppTheme.purple1.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                    bottomLeft: Radius.circular(4)),
                border: Border.all(color: AppTheme.purple3.withOpacity(0.4))),
            child: Text(l10n.starsConsulting,
                style: const TextStyle(
                    color: AppTheme.muted,
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 14,
                    fontStyle: FontStyle.italic))),
      ]),
    );
  }

  Widget _buildInput(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
          color: AppTheme.deep,
          border: Border(
              top: BorderSide(color: AppTheme.purple3.withOpacity(0.3)))),
      child: Row(children: [
        Expanded(
            child: Container(
          decoration: BoxDecoration(
              color: AppTheme.purple1,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.purple3.withOpacity(0.4))),
          child: TextField(
              controller: _messageController,
              style: const TextStyle(
                  color: AppTheme.white, fontFamily: 'Nunito', fontSize: 14),
              decoration: InputDecoration(
                  hintText: l10n.sendMessage,
                  hintStyle: const TextStyle(
                      color: AppTheme.muted, fontFamily: 'Nunito'),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              onSubmitted: (_) => _sendMessage(),
              maxLines: null),
        )),
        const SizedBox(width: 8),
        GestureDetector(
            onTap: _sendMessage,
            child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppTheme.gold, AppTheme.violet]),
                    borderRadius: BorderRadius.circular(23),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.violet.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]),
                child: const Center(
                    child: Text('✨', style: TextStyle(fontSize: 20))))),
      ]),
    );
  }
}
