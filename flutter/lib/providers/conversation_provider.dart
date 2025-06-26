import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';

class ConversationNotifier extends StateNotifier<List<ChatMessage>> {
  ConversationNotifier() : super([]);

  void addMessage(ChatMessage msg) {
    state = [...state, msg];
  }
}

final conversationProvider = StateNotifierProvider<ConversationNotifier, List<ChatMessage>>(
  (ref) => ConversationNotifier(),
);
