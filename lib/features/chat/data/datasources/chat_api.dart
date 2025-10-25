import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/chat_message.dart';

class ChatApi {
  final String baseUrl; // ví dụ: http://10.0.2.2:8000 (Android)
  ChatApi(this.baseUrl);

  Future<ChatMessage> chat(String userId, String message) async {
    final url = Uri.parse('$baseUrl/chat');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'message': message}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return ChatMessage(role: 'assistant', text: data['reply'] as String);
    } else {
      throw Exception('Chat API error: ${res.statusCode} - ${res.body}');
    }
  }
}
