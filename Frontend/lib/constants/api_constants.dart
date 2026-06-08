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
  static const String n8nBaseUrl = 'https://TON_INSTANCE_N8N';
  static const String n8nAuthHeader = 'TON_SECRET_HEADER_AUTH';
}
