import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../services/application_service.dart';
import 'authentication/authentication_page.dart';
import 'main_page.dart';

class ChatGptApp extends StatefulWidget {
  const ChatGptApp({super.key});

  @override
  State<ChatGptApp> createState() => _ChatGptAppState();
}

class _ChatGptAppState extends State<ChatGptApp> {
  Future _initializeApplication(BuildContext context) async {
    final applicationProvider = context.read<ApplicationProvider>();
    if (applicationProvider.status != ApplicationStatus.readyApp) {
      await applicationProvider.initializeApplication(context);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeApplication(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final applicationProvider = context.watch<ApplicationProvider>();
    final status = applicationProvider.status;
    switch (status) {
      case ApplicationStatus.applicationError:
        Timer.periodic(const Duration(seconds: 5), (timer) async {
          await _initializeApplication(context);
          timer.cancel();
        });
        return Scaffold(
          backgroundColor: themeData.colorScheme.secondary,
          body: Center(
            child: Lottie.asset(
              'assets/lottie/404.json',
              height: 120.0,
              width: MediaQuery.of(context).size.width,
              repeat: true,
            ),
          ),
        );

      case ApplicationStatus.readyApp:
        return StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const MainPage();
            } else {
              return const AuthenticationPage();
            }
          },
        );

      case ApplicationStatus.welcome:
        return Scaffold(
          backgroundColor: themeData.colorScheme.secondaryContainer,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    "Welcome to the App!",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Lottie.asset(
                    'assets/lottie/ai-robot.json',
                    height: 160.0,
                    width: MediaQuery.of(context).size.width,
                    repeat: true,
                  ),
                  const SizedBox(height: 16.0),
                  const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Text(
                      "This is a chat app that uses GPT-3 to generate responses. Let's get started!",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => context.read<ApplicationProvider>().changeStatus(ApplicationStatus.readyApp),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );

      default:
        return Scaffold(
          backgroundColor: themeData.colorScheme.secondary,
          body: Center(
            child: Lottie.asset(
              'assets/lottie/meditating-robot.json',
              height: 360.0,
              width: MediaQuery.of(context).size.width,
              repeat: true,
            ),
          ),
        );
    }
  }
}
