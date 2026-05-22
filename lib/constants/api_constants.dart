class ApiConstants {
  // Pour un vrai appareil Android sur le même WiFi que le PC :
  // Lancez "ipconfig" sur le PC → IPv4 Address → mettez cette IP ici
  // Exemple : 'http://192.168.1.15:8000'
  static const String baseUrl = 'http://192.168.1.103:8000';

  static const String chatEndpoint = '/chat';
  static const String healthEndpoint = '/health';

  // Gemini + RAG peut prendre 10-60 secondes selon la charge
  static const int timeoutSeconds = 90;
}
