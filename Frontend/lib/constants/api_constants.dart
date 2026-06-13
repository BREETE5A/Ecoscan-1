class ApiConstants {
  // Chatbot RAG (Gemini + ChromaDB)
  static const String baseUrl = 'https://ecoscan-chatbot.onrender.com';
  static const String chatEndpoint = '/chat';
  static const String healthEndpoint = '/health';
  static const int timeoutSeconds = 90;

  // Modèle YOLOv8 online (détection déchets)
  static const String scanBaseUrl = 'https://ecoscan-model-online.onrender.com';
  static const String scanEndpoint = '/scan';
  static const int scanTimeoutSeconds = 60;

  // n8n Automation Webhooks
  static const String n8nBaseUrl = 'https://badora.app.n8n.cloud';
  static const String n8nAuthHeader = 'ecoscan';

  // OpenWeatherMap — injecté via --dart-define=OWM_KEY=xxx au build
  // Fallback de dev uniquement, ne pas commiter une vraie clé ici
  static const String owmKey = String.fromEnvironment(
    'OWM_KEY',
    defaultValue: '40bbb318e5d3379c017f100b4a79b9b9',
  );
}
