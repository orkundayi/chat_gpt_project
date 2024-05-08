import 'package:cloud_firestore/cloud_firestore.dart';

enum Role {
  assistant,
  user,
}

class MessageData {
  final Role role;
  final String content;
  DateTime? sentTime;

  MessageData({
    required this.role,
    required this.content,
    required this.sentTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': roleToString(role),
      'content': content,
      'sentTime': sentTime != null ? Timestamp.fromDate(sentTime!) : null,
    };
  }

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      role: json['role'] == 'assistant' ? Role.assistant : Role.user,
      content: json['content'],
      sentTime: json['sentTime'] != null ? (json['sentTime'] as Timestamp).toDate() : null,
    );
  }

  String roleToString(Role role) {
    return role == Role.assistant ? 'assistant' : 'user';
  }
}
