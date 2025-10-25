import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/chat_api.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../providers/chat_controller.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => ChatController(
            repo: ChatRepositoryImpl(
              ChatApi(
                const String.fromEnvironment(
                  'FINANCE_API_BASE', // truyền bằng --dart-define
                  defaultValue: 'http://10.0.2.2:8000',
                ),
              ),
            ),
            userId: 'user_123', // TODO: lấy từ auth của bạn
          ),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _controller = TextEditingController();
  final _quick = const [
    'Mục nào đang vượt ngân sách?',
    'Tôi nên cắt giảm ở đâu tuần này?',
    'Có giao dịch bất thường gần đây không?',
    'Tỷ lệ chi/thu tháng này?',
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Cố vấn chi tiêu')),
      body: Column(
        children: [
          // gợi ý nhanh
          SizedBox(
            height: 46,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemBuilder:
                  (_, i) => ActionChip(
                    label: Text(_quick[i]),
                    onPressed: () => _sendText(_quick[i]),
                  ),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _quick.length,
            ),
          ),
          // khung chat
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: vm.messages.length,
              itemBuilder: (_, i) {
                final m = vm.messages[i];
                final me = m.role == 'user';
                return Align(
                  alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color:
                          me
                              ? Colors.deepPurple.shade100
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),
          if (vm.loading) const LinearProgressIndicator(minHeight: 2),
          // input
          SafeArea(
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Hỏi về chi tiêu tháng này...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(context),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _send(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send(BuildContext context) {
    final text = _controller.text;
    _controller.clear();
    context.read<ChatController>().send(text);
  }

  void _sendText(String t) {
    _controller.text = t;
    _send(context);
  }
}
