import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref.read(chatServiceProvider));
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final ChatService _service;

  ChatNotifier(this._service) : super([ChatMessage.welcome]);

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Message utilisateur
    state = [...state, ChatMessage.user(trimmed)];

    // Indicateur de chargement
    final loading = ChatMessage.loading();
    state = [...state, loading];

    try {
      final response = await _service.sendMessage(trimmed);
      state = state
          .map((m) => m.id == loading.id ? m.copyWith(text: response, isLoading: false) : m)
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

  void clearChat() {
    state = [ChatMessage.welcome];
  }
}
