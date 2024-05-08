import 'dart:async';

import 'package:chat_gpt_project/models/chat_model.dart';
import 'package:chat_gpt_project/utils/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:provider/provider.dart';

import '../../models/message_data.dart';
import '../../services/firebase_chat_service.dart';
import '../../utils/mixin/dialog_composer.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
  static const String routeName = '/chat-page';
}

class _ChatPageState extends State<ChatPage> with DialogComposer {
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  ChatModel? chat;
  Function? callback;

  @override
  void didChangeDependencies() {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    chat = arguments['chat'] as ChatModel?;
    callback = arguments['callback'] as Function?;
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
  }

  void scrollToBottom() {
    Timer(const Duration(seconds: 1), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    switch (chat) {
      case null:
        return const CircularProgressIndicator();
      default:
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            if (didPop) {
              if (callback != null) {
                callback!();
              }
            }
          },
          child: Scaffold(
            backgroundColor: themeData.colorScheme.secondary,
            appBar: AppBar(
              backgroundColor: themeData.colorScheme.primaryContainer,
              title: Text(chat!.name),
            ),
            body: StreamBuilder(
              stream: context.read<FirebaseChatService>().getChatMessagesStream(FirebaseAuth.instance.currentUser!.uid, chat!.id),
              builder: (BuildContext context, AsyncSnapshot<List<MessageData>> snapshot) {
                if (snapshot.hasData) {
                  final List<MessageData> messages = snapshot.data!;
                  return SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 26,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: messages.length,
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                final MessageData message = messages[index];
                                return BubbleNormal(
                                  text: message.content,
                                  isSender: message.role == Role.user,
                                  color: message.role == Role.user ? Colors.blue.shade100 : Colors.grey.shade200,
                                  bubbleRadius: 16,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                );
                              },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: themeData.colorScheme.primaryContainer,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                  child: SizedBox(
                                    height: 72,
                                    width: MediaQuery.of(context).size.width - 120,
                                    child: CustomTextField(
                                      expands: true,
                                      controller: controller,
                                      labelText: null,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: sendMsg,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: themeData.colorScheme.primary,
                                    ),
                                    child: Icon(
                                      Icons.send,
                                      color: themeData.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        );
    }
  }

  void sendMsg() async {
    String text = controller.text;
    controller.clear();
    try {
      if (text.isNotEmpty) {
        final MessageData userMessage = MessageData(role: Role.user, content: text, sentTime: DateTime.now());
        if (mounted) {
          await context.read<FirebaseChatService>().addNewMessageToChat(chat!.id, userMessage);
        }
        scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(seconds: 1), curve: Curves.easeOut);
        final MessageData message = MessageData(role: Role.user, content: text, sentTime: null);
        MessageData? chatGptMessage;
        if (mounted) {
          chatGptMessage = await context.read<FirebaseChatService>().sendNewMessageToChatGPT(context, message, chat!.id);
        }
        if (chatGptMessage != null) {
          if (mounted) {
            await context.read<FirebaseChatService>().addNewMessageToChat(chat!.id, chatGptMessage);
          }
          scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(seconds: 1), curve: Curves.easeOut);
        }
      }
    } on Exception {
      if (mounted) {
        showFlushBar(context, 'Some error occurred, please try again!');
      }
    }
  }
}
