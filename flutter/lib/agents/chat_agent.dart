import 'dart:convert';
import '../services/openai_webrtc_service.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'supervisor_agent.dart';
import '../models/message.dart';
import 'dart:async';

class ChatAgent {
  final OpenAIWebRTCService webrtc;
  final SupervisorAgent supervisor;
  final _controller = StreamController<ChatMessage>.broadcast();

  Stream<ChatMessage> get responses => _controller.stream;

  ChatAgent(this.webrtc, this.supervisor);

  Future<void> sendUserText(String text) async {
    final payload = jsonEncode({'user_message': text});
    await webrtc.dataChannel?.send(RTCDataChannelMessage(payload));
  }

  Future<void> handleDataChannelMessage(String data) async {
    final msg = jsonDecode(data);
    if (msg['assistant_message'] != null) {
      _controller.add(ChatMessage(sender: 'assistant', content: msg['assistant_message'] as String));
    } else if (msg['tool_call'] != null) {
      final toolName = msg['tool_call']['name'];
      if (toolName == 'getNextResponseFromSupervisor') {
        final context =
            msg['tool_call']['args']['relevantContextFromLastUserMessage'] ?? '';
        final response = await supervisor.getNextResponse(context);
        final payload = jsonEncode({'tool_response': response});
        await webrtc.dataChannel?.send(RTCDataChannelMessage(payload));
      }
    }
  }
}
