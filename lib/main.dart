import 'dart:convert';

import 'package:chat_gpt_project/models/message_data.dart';
import 'package:chat_gpt_project/services/firebase_chat_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';

import 'package:provider/provider.dart';
import 'models/chat_request.dart';
import 'services/application_service.dart';
import 'utils/navigation/init_get_it.dart';
import 'utils/navigation/navigation_service.dart';
import 'pages/chat_gpt_app.dart';
import 'services/firebase_service.dart';

void main() async {
  await initMainApp();
  runApp(const MainApp());
}

Future<void> initMainApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  initGetIt();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FirebaseService()),
        ChangeNotifierProvider(create: (context) => ApplicationProvider()),
        ChangeNotifierProvider(create: (context) => FirebaseChatService()),
      ],
      child: GlobalLoaderOverlay(
        useDefaultLoading: true,
        child: MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          navigatorKey: NavigationService.instance.navigatorKey,
          navigatorObservers: [
            NavigationService.instance.routeObserver,
          ],
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
          home: const ChatGptApp(),
        ),
      ),
    );
  }
}

class MainApp1 extends StatefulWidget {
  const MainApp1({super.key});

  @override
  State<MainApp1> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp1> {
  String title = 'HTTP Post Request';
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () async {
              /* const apiKey = "sk-proj-1NKr3ajgdsO92dqFgtNtT3BlbkFJVdPmhMJM9AV0N63zfeV6";
              var request = ChatRequest(
                model: 'gpt-3.5-turbo',
                messages: [
                  MessageData(role: Role.user, content: "Hello!", sentTime: null),
                  MessageData(role: Role.assistant, content: "Hello! How can I help you today?", sentTime: null),
                  MessageData(role: Role.user, content: "I need help with my computer. It's not working.", sentTime: null),
                ],
              );

              var response = await http.post(
                Uri.parse("https://api.openai.com/v1/chat/completions"),
                headers: {"Authorization": "Bearer $apiKey", "Content-Type": "application/json"},
                body: jsonEncode(request.toJson()),
              );
              debugPrint(response.body);
              var json = jsonDecode(response.body);
              title = json["choices"][0]["message"]["content"]; */
              if (context.mounted) {
                context.read<FirebaseChatService>().addNewMessageToChat(
                      'sLyEF9y2hNAPBzoAqr1t',
                      MessageData(role: Role.user, content: title + title, sentTime: DateTime.now()),
                    );
                /* context.read<FirebaseChatService>().createANewChat(
                      context,
                      MessageData(role: Role.assistant, content: title, sentTime: DateTime.now()),
                    ); */
              }
              setState(() {});
            },
            child: const Text('Hello World!'),
          ),
          Text(title),
        ],
      ),
    );
  }
}
