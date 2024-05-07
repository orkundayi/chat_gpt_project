import 'dart:async';
import 'package:chat_gpt_project/services/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../firebase_options.dart';
import '../utils/mixin/dialog_composer.dart';

class ApplicationProvider with ChangeNotifier, DiagnosticableTreeMixin, DialogComposer {
  ApplicationProvider({
    this.status = ApplicationStatus.none,
  }) : super();

  ApplicationStatus status;
  Future<void> initializeApplication(BuildContext context) async {
    try {
      if (status == ApplicationStatus.none) {
        status = ApplicationStatus.initializingApp;
      }
      final authenticationProvider = context.read<FirebaseService>();
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      if (context.mounted) await checkFirstRun(context);
      await clearSecureStorageOnReinstall();
      await authenticationProvider.getCurrentUser();
      if (context.mounted) {
        authenticationProvider.currentUser == null
            ? showFlushBar(context, 'Welcome to the app! Please sign in to continue.')
            : showFlushBar(context, 'Wellcome Back ${authenticationProvider.currentUser!.email}!');
      }
    } catch (e) {
      status = ApplicationStatus.applicationError;
    } finally {
      notifyListeners();
    }
  }

  Future<void> changeStatus(ApplicationStatus status) async {
    this.status = status;
    notifyListeners();
  }

  Future<void> checkFirstRun(BuildContext context) async {
    if (!await SharedPreferences.getInstance().then((value) => value.getBool('hasRunBefore') ?? false)) {
      status = ApplicationStatus.welcome;
    } else {
      status = ApplicationStatus.readyApp;
    }
  }

  Future<void> clearSecureStorageOnReinstall() async {
    String key = 'hasRunBefore';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasRunBefore = prefs.getBool(key) ?? false;
    if (!hasRunBefore) {
      FlutterSecureStorage storage = const FlutterSecureStorage();
      await storage.deleteAll();
      FirebaseAuth.instance.signOut();
      prefs.setBool(key, true);
    }
  }
}

enum ApplicationStatus {
  none,
  initializingApp,
  tryingAutoLogin,
  applicationError,
  welcome,
  readyApp,
}
