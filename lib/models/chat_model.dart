import 'message_data.dart';

class ChatModel {
  String id;
  String name;
  String uid;
  List<MessageData>? messages;

  ChatModel({
    required this.id,
    required this.name,
    required this.uid,
    required this.messages,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      name: json['name'],
      uid: json['uid'],
      messages: json['messages'] != null ? (json['messages'] as List).map((message) => MessageData.fromJson(message)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'uid': uid,
      'messages': messages?.map((message) => message.toJson()).toList(),
    };
  }
}
