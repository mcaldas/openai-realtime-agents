import 'package:flutter_test/flutter_test.dart';
import 'package:chat_supervisor_app/agents/chat_agent.dart';
import 'package:chat_supervisor_app/agents/supervisor_agent.dart';
import 'package:chat_supervisor_app/services/openai_webrtc_service.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FakeWebRTCService extends OpenAIWebRTCService {
  @override
  RTCDataChannel? get dataChannel => _controller;
  final _controller = FakeDataChannel();
}

class FakeDataChannel implements RTCDataChannel {
  final List<String> sent = [];
  @override
  Future<void> send(RTCDataChannelMessage message) async {
    sent.add(message.text);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSupervisorAgent extends SupervisorAgent {
  @override
  Future<String> getNextResponse(String context) async => 'ok';
}

void main() {
  test('tool call routed to supervisor', () async {
    dotenv.testLoad(fileInput: 'OPENAI_API_KEY=dummy');
    final service = FakeWebRTCService();
    final supervisor = FakeSupervisorAgent();
    final agent = ChatAgent(service, supervisor);
    await agent.handleDataChannelMessage('{"tool_call": {"name": "getNextResponseFromSupervisor", "args": {"relevantContextFromLastUserMessage": "hello"}}}');
    final channel = service.dataChannel as FakeDataChannel;
    expect(channel.sent.isNotEmpty, true);
  });
}
