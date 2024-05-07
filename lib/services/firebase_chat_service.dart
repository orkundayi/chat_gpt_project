import 'package:chat_gpt_project/models/chat_model.dart';
import 'package:chat_gpt_project/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/message_data.dart';
import '../utils/mixin/dialog_composer.dart';

class FirebaseChatService with ChangeNotifier, DiagnosticableTreeMixin, DialogComposer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createANewChat(BuildContext context, MessageData message) async {
    final FirebaseService firebaseService = context.read<FirebaseService>();
    final currentUser = firebaseService.currentUser;
    if (currentUser == null) {
      showFlushBar(context, 'Please sign in to continue');
      firebaseService.signOut();
      return;
    }
    try {
      final uniqueId = _firestore.collection('chats').doc().id;
      ChatModel chat = ChatModel(id: uniqueId, uid: currentUser.uid, name: "Chat ${uniqueId.substring(0, 5)}", messages: [message]);

      _firestore.collection('chats').doc(uniqueId).set(chat.toJson());
    } catch (e) {
      debugPrint('Error adding message: $e');
    }
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
      return _firestore.collection('chats').doc(chatId).collection('messages').orderBy('sentTime', descending: false).snapshots().map((snapshot) => snapshot.docs
          .map((doc) => MessageData(
                role: doc['role'] == 'assistant' ? Role.assistant : Role.user,
                content: doc['content'],
                sentTime: (doc['sentTime'] as Timestamp).toDate(),
              ))
          .toList());
    } catch (e) {
      debugPrint('Error getting chat messages: $e');
      rethrow;
    }
  }
}
