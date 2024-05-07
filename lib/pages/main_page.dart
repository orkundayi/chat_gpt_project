import 'package:chat_gpt_project/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firebase_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
      body: const MainApp1(),
    );
  }
}
