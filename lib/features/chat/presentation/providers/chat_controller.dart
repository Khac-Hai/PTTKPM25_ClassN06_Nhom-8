import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatController extends ChangeNotifier {
  final ChatRepository repo;
  final String userId;
  ChatController({required this.repo, required this.userId});

  final List<ChatMessage> messages = [];
  bool loading = false;

  Future<void> send(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    messages.add(ChatMessage(role: 'user', text: t));
    loading = true;
    notifyListeners();
    try {
      final reply = await repo.ask(userId, t);
      messages.add(reply);
    } catch (e) {
      messages.add(
        ChatMessage(
          role: 'assistant',
          text:
              'Không kết nối được server. Kiểm tra FINANCE_API_BASE hoặc mạng.',
        ),
      );
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
