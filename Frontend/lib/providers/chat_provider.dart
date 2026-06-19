import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../l10n/app_strings.dart';
import 'locale_provider.dart';

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

/// Message pré-rempli depuis l'écran de résultat de scan — consommé une seule fois
final pendingChatContextProvider = StateProvider<String?>((ref) => null);

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final lang = ref.read(localeProvider).languageCode;
  final greeting = AppStrings.of(lang).botGreeting;
  return ChatNotifier(ref.read(chatServiceProvider), greeting, lang);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final ChatService _service;
  final String _lang;

  ChatNotifier(this._service, String greeting, this._lang)
      : super([ChatMessage.bot(greeting)]);

  // Historique sous forme [{role, content}] pour le backend
  List<Map<String, String>> get _history {
    return state
        .where((m) => !m.isLoading && m.text.isNotEmpty)
        .skip(1) // skip welcome
        .map((m) => {'role': m.isUser ? 'user' : 'bot', 'content': m.text})
        .toList();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    state = [...state, ChatMessage.user(trimmed)];

    final loading = ChatMessage.loading();
    state = [...state, loading];

    try {
      final response = await _service.sendMessage(trimmed, history: _history);
      state = state
          .map((m) => m.id == loading.id
              ? m.copyWith(text: response, isLoading: false)
              : m)
          .toList();
    } catch (e) {
      final errMsg = e.toString().replaceFirst('Exception: ', '');
      state = state
          .map((m) => m.id == loading.id
              ? m.copyWith(text: '❌ $errMsg', isLoading: false)
              : m)
          .toList();
    }
  }

  void setFeedback(String messageId, bool liked) {
    state = state
        .map((m) => m.id == messageId ? m.copyWith(feedback: liked) : m)
        .toList();
    _saveFeedback(messageId, liked);
  }

  void _saveFeedback(String messageId, bool liked) {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chatFeedback')
          .doc(messageId)
          .set({
        'liked': liked,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Feedback save error: $e');
    }
  }

  void clearChat() => state = [ChatMessage.welcomeFor(_lang)];

  void updateWelcomeMessage(String greeting) {
    if (state.length == 1 && !state.first.isUser) {
      state = [ChatMessage.bot(greeting)];
    }
  }
}
