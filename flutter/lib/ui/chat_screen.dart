import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/conversation_provider.dart';
import '../services/openai_webrtc_service.dart';
import '../agents/chat_agent.dart';
import '../agents/supervisor_agent.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../models/message.dart';
import 'widgets/status_banner.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final OpenAIWebRTCService _service;
  late final ChatAgent _chatAgent;
  late final SupervisorAgent _supervisor;
  final _controller = TextEditingController();
  String _status = 'waiting';

  @override
  void initState() {
    super.initState();
    _service = OpenAIWebRTCService();
    _supervisor = SupervisorAgent();
    _chatAgent = ChatAgent(_service, _supervisor);
    _initConnection();
  }

  Future<void> _initConnection() async {
    final offer = await _service.createOffer();
    // would POST offer and apply answer here
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(conversationProvider.notifier).addMessage(ChatMessage(sender: 'user', content: text));
    _controller.clear();
    final payload = jsonEncode({'user_message': text});
    _service.dataChannel?.send(RTCDataChannelMessage(payload));
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(conversationProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Supervisor')),
      body: Column(
        children: [
          StatusBanner(text: _status),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(messages[i].sender),
                subtitle: Text(messages[i].content),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                ),
              ),
              IconButton(onPressed: _send, icon: const Icon(Icons.send))
            ],
          )
        ],
      ),
    );
  }
}
