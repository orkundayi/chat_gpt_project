import 'package:chat_gpt_project/models/message_data.dart';

class ChatRequest {
  final String model;
  final List<MessageData> messages;

  ChatRequest({
    required this.model,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}
