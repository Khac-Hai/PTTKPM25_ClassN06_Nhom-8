import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_api.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatApi api;
  ChatRepositoryImpl(this.api);

  @override
  Future<ChatMessage> ask(String userId, String message) {
    return api.chat(userId, message);
  }
}
