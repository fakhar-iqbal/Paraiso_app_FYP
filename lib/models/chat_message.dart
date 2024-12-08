class ChatMessage {
  final String text;
  final bool isUserMessage;
  final String? imageUrl;

  ChatMessage({
    required this.text, 
    required this.isUserMessage, 
    this.imageUrl
  });
}