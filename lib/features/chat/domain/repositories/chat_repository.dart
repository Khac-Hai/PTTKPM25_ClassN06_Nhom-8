import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<ChatMessage> ask(String userId, String message);
}
