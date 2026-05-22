class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });

  ChatMessage copyWith({
    String? text,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      isUser: isUser,
      timestamp: timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static String _uid() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  factory ChatMessage.user(String text) => ChatMessage(
        id: _uid(),
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.bot(String text) => ChatMessage(
        id: _uid(),
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.loading() => ChatMessage(
        id: _uid(),
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
        isLoading: true,
      );

  static ChatMessage get welcome => ChatMessage.bot(
        'Bonjour ! Je suis EcoBot 🌿\n\n'
        'Posez-moi vos questions sur le tri et le recyclage au Maroc !',
      );
}
