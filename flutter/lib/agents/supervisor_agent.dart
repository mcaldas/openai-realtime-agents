import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupervisorAgent {
  static const _instructions = r'''
You are an expert customer service supervisor agent, tasked with providing real-time guidance to a more junior agent that's chatting directly with the customer. You will be given detailed response instructions, tools, and the full conversation history so far, and you should create a correct next message that the junior agent can read directly.
''';

  Future<String> getNextResponse(String context) async {
    final body = {
      'model': 'gpt-4.1',
      'messages': [
        {'role': 'system', 'content': _instructions},
        {'role': 'user', 'content': context},
      ],
      'tools': [
        {
          'type': 'function',
          'function': {
            'name': 'lookupPolicyDocument',
            'parameters': {'type': 'object', 'properties': {'topic': {'type': 'string'}}}
          }
        }
      ]
    };
    final resp = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY']}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    final data = jsonDecode(resp.body);
    final msg = data['choices'][0]['message'];
    return msg['content'];
  }
}
