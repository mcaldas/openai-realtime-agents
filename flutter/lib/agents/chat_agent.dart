import 'dart:convert';
import '../services/openai_webrtc_service.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'supervisor_agent.dart';

class ChatAgent {
  final OpenAIWebRTCService webrtc;
  final SupervisorAgent supervisor;

  ChatAgent(this.webrtc, this.supervisor);

  Future<void> handleDataChannelMessage(String data) async {
    final msg = jsonDecode(data);
    if (msg['tool_call'] != null) {
      final toolName = msg['tool_call']['name'];
      if (toolName == 'getNextResponseFromSupervisor') {
        final context = msg['tool_call']['args']['relevantContextFromLastUserMessage'] ?? '';
        final response = await supervisor.getNextResponse(context);
        final payload = jsonEncode({'tool_response': response});
        await webrtc.dataChannel?.send(RTCDataChannelMessage(payload));
      }
    }
  }
}
