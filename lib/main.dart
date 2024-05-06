import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String title = 'HTTP Post Request';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () async {
                  const apiKey = "sk-proj-1NKr3ajgdsO92dqFgtNtT3BlbkFJVdPmhMJM9AV0N63zfeV6";
                  var response = await http.post(
                    Uri.parse("https://api.openai.com/v1/chat/completions"),
                    headers: {"Authorization": "Bearer $apiKey", "Content-Type": "application/json"},
                    body: jsonEncode(
                      {
                        "model": "gpt-3.5-turbo",
                        "messages": [
                          {"role": "user", "content": "Hello!"},
                          {"role": "assistant", "content": "Hello! How can I help you today?"},
                          {"role": "user", "content": "I need help with my computer. It's not working."}
                        ]
                      },
                    ),
                  );
                  debugPrint(response.body);
                  var json = jsonDecode(response.body);
                  title = json["choices"][0]["message"]["content"];

                  setState(() {});
                },
                child: const Text('Hello World!'),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
