import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:chat_gpt_project/models/chat_model.dart';
import 'package:chat_gpt_project/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

import '../models/chat_request.dart';
import '../models/message_data.dart';
import '../utils/mixin/dialog_composer.dart';

class FirebaseChatService with ChangeNotifier, DiagnosticableTreeMixin, DialogComposer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final apiKey = "sk-proj-1NKr3ajgdsO92dqFgtNtT3BlbkFJVdPmhMJM9AV0N63zfeV6";

  Future<ChatModel?> createANewChat(BuildContext context, MessageData message) async {
    try {
      final FirebaseService firebaseService = context.read<FirebaseService>();
      final currentUser = firebaseService.currentUser;
      if (currentUser == null) {
        showFlushBar(context, 'Please sign in to continue');
        firebaseService.signOut();
        return null;
      }
      context.loaderOverlay.show();
      final uniqueId = _firestore.collection('chats').doc().id;

      var request = ChatRequest(
        model: 'gpt-3.5-turbo',
        messages: [
          MessageData(role: Role.user, content: message.content, sentTime: null),
        ],
      );

      var response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {"Authorization": "Bearer $apiKey", "Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      var json = jsonDecode(response.body);
      MessageData responseMessage = MessageData(role: Role.assistant, content: json["choices"][0]["message"]["content"], sentTime: DateTime.now());
      ChatModel chat = ChatModel(id: uniqueId, uid: currentUser.uid, name: "Chat ${uniqueId.substring(0, 5)}", messages: [responseMessage]);
      _firestore.collection('chats').doc(uniqueId).set(chat.toJson());
      return chat;
    } catch (e) {
      debugPrint('Error adding message: $e');
    } finally {
      if (context.mounted) {
        context.loaderOverlay.hide();
      }
    }
    return null;
  }

  Future<MessageData?> sendNewMessageToChatGPT(BuildContext context, MessageData message, String chatId) async {
    try {
      context.loaderOverlay.show();
      final List<MessageData> messages = [];
      await _firestore.collection('chats').doc(chatId).get().then((value) {
        messages.addAll((value.data()!['messages'] as List).map((e) => MessageData.fromJson(e)).toList());
      });
      messages.add(message);
      for (final msg in messages) {
        msg.sentTime = null;
      }
      var request = ChatRequest(model: 'gpt-3.5-turbo', messages: messages);

      var response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {"Authorization": "Bearer $apiKey", "Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );
      if (response.statusCode != 200) {
        if (context.mounted) {
          showFlushBar(context, "Error sending message to GPT-3.5 Turbo. Please try again later.");
        }
        return null;
      }

      var json = jsonDecode(response.body);
      MessageData responseMessage = MessageData(role: Role.assistant, content: json["choices"][0]["message"]["content"], sentTime: DateTime.now());
      return responseMessage;
    } catch (e) {
      debugPrint('Error sending message to GPT-3.5 Turbo: $e');
      if (context.mounted) {
        showFlushBar(context, "Error sending message to GPT-3.5 Turbo. Please try again later.");
      }
    } finally {
      if (context.mounted) {
        context.loaderOverlay.hide();
      }
    }
    return null;
  }

  Future<void> addNewMessageToChat(String chatId, MessageData message) async {
    try {
      await _firestore.collection('chats').doc(chatId).set(
        {
          'messages': FieldValue.arrayUnion([message.toJson()]),
        },
        SetOptions(
          merge: true,
        ),
      );

      await _firestore.collection('chats').doc(chatId).get().then((value) => debugPrint(value.data().toString()));
    } catch (e) {
      debugPrint('Error adding message: $e');
    }
  }

  Stream<List<MessageData>> getChatMessagesStream(String uid, String chatId) {
    try {
      return _firestore.collection('chats').doc(chatId).snapshots().map((event) {
        List<MessageData> messages = (event.data()!['messages'] as List).map((e) => MessageData.fromJson(e)).toList();
        messages.sort((a, b) => a.sentTime!.compareTo(b.sentTime!));
        return messages;
      });
    } catch (e) {
      debugPrint('Error getting chat messages: $e');
      rethrow;
    }
  }

  Future<List<ChatModel>> getUserChats(BuildContext context) async {
    try {
      var currentUser = context.read<FirebaseService>().currentUser;
      if (currentUser == null) {
        try {
          await context.read<FirebaseService>().getCurrentUser();
          if (context.mounted) {
            currentUser = context.read<FirebaseService>().currentUser;
          }
          if (currentUser == null) {
            if (context.mounted) {
              showFlushBar(context, "Please sign in to continue");
              context.read<FirebaseService>().signOut();
            }
            return [];
          }
        } catch (e) {
          debugPrint('Error getting user chats: $e');
          rethrow;
        }
      }
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('chats').where('uid', isEqualTo: currentUser!.uid).get();
      return snapshot.docs.map((doc) => ChatModel.fromJson(doc.data())).toList();
    } catch (e) {
      debugPrint('Error getting user chats: $e');
      rethrow;
    }
  }

  Future<void> deleteChat(String id) async {
    try {
      return await _firestore.collection('chats').doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting chat: $e');
      rethrow;
    }
  }
}
