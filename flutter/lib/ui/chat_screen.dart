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
  final _renderer = RTCVideoRenderer();
  String _status = 'waiting';

  @override
  void initState() {
    super.initState();
    _service = OpenAIWebRTCService();
    _supervisor = SupervisorAgent();
    _chatAgent = ChatAgent(_service, _supervisor);
    _renderer.initialize();
    _initConnection();
    _chatAgent.responses.listen((msg) {
      ref.read(conversationProvider.notifier).addMessage(msg);
    });
  }

  @override
  void dispose() {
    _renderer.dispose();
    super.dispose();
  }

  Future<void> _initConnection() async {
    final offer = await _service.createOffer();
    final answer = await _service.sendOfferToOpenAI(offer);
    await _service.applyAnswer(answer);
    _service.dataChannel?.onMessage = (msg) {
      _chatAgent.handleDataChannelMessage(msg.text);
    };
    _service.connection?.onTrack = (event) {
      if (event.track.kind == 'audio') {
        _renderer.srcObject = event.streams.first;
      }
    };
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(conversationProvider.notifier).addMessage(ChatMessage(sender: 'user', content: text));
    _controller.clear();
    _chatAgent.sendUserText(text);
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
