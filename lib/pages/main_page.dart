import 'dart:async';

import 'package:chat_gpt_project/models/chat_model.dart';
import 'package:chat_gpt_project/services/firebase_chat_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/message_data.dart';
import '../services/firebase_service.dart';
import 'chat/chat_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<ChatModel> chatList = [];

  @override
  void initState() {
    super.initState();
    getUserChats();
  }

  Future<void> getUserChats() async {
    final FirebaseChatService firebaseChatService = context.read<FirebaseChatService>();
    final List<ChatModel> chats = await firebaseChatService.getUserChats(context);
    setState(() {
      chatList = chats;
    });
  }

  Future<void> _refreshChats() async {
    await getUserChats();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: themeData.colorScheme.secondary,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Main Page',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: themeData.colorScheme.primaryContainer,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: () async {
              await context.read<FirebaseService>().signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshChats,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          height: MediaQuery.of(context).size.height - AppBar().preferredSize.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (chatList.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: chatList.length,
                    itemBuilder: (context, index) {
                      final ChatModel chat = chatList[index];
                      return Slidable(
                        endActionPane: ActionPane(
                          extentRatio: 1 / 3,
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              borderRadius: BorderRadius.circular(12.0),
                              onPressed: (context) async {
                                await context.read<FirebaseChatService>().deleteChat(chat.id);
                                await getUserChats();
                              },
                              backgroundColor: Colors.red,
                              icon: Icons.delete,
                            ),
                          ],
                        ),
                        key: Key(chat.id),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(ChatPage.routeName, arguments: {
                              'chat': chat,
                              'callback': () async {
                                await getUserChats();
                              },
                            });
                          },
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 24.0,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: themeData.colorScheme.primaryContainer.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chat.name,
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8.0,
                                  ),
                                  Text(
                                    chat.messages!.last.content,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else ...[
                  const SizedBox(
                    height: 200,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final ChatModel? chat = await createNewChat(context);
                      if (chat != null) {
                        await getUserChats();
                        if (context.mounted) {
                          Navigator.of(context).pushNamed(ChatPage.routeName, arguments: {
                            'chat': chat,
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: themeData.colorScheme.primaryContainer,
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    ),
                    child: const Text(
                      "Create a new chat to get started!",
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      floatingActionButton: InkWell(
        onTap: () async {
          final ChatModel? chat = await createNewChat(context);
          if (chat != null) {
            await getUserChats();
            if (context.mounted) {
              Navigator.of(context).pushNamed(ChatPage.routeName, arguments: {
                'chat': chat,
              });
            }
          }
        },
        child: Opacity(
          opacity: 0.8,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: themeData.colorScheme.onPrimary,
              radius: 36.0,
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.add,
                    size: 40.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<ChatModel?> createNewChat(BuildContext context) async {
    final FirebaseChatService firebaseChatService = context.read<FirebaseChatService>();
    return await firebaseChatService.createANewChat(
      context,
      MessageData(
        role: Role.user,
        content: 'Hello!',
        sentTime: DateTime.now(),
      ),
    );
  }
}
