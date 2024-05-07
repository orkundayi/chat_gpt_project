import 'package:chat_gpt_project/models/user.dart';
import 'package:chat_gpt_project/utils/extensions/string_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/mixin/dialog_composer.dart';
import '../utils/navigation/navigation_service.dart';

class FirebaseService with ChangeNotifier, DiagnosticableTreeMixin, DialogComposer {
  UserModel? _currentUser;
  FirebaseService() : super();

  get currentUser => _currentUser;
  Future<void> signOut() async {
    try {
      NavigationService.instance.showLoaderOverlay();
      await FirebaseAuth.instance.signOut();
      _currentUser = null;
      notifyListeners();
    } finally {
      NavigationService.instance.hideLoaderOverlay();
    }
  }

  Future<void> signInWithEmailAndPassword(BuildContext context, String input, String password) async {
    try {
      NavigationService.instance.showLoaderOverlay();
      String email;
      if (input.isValidEmail) {
        email = input;
      } else {
        showFlushBar(context, 'Please enter a valid email address');
        return;
      }
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if (user != null) {
        await getCurrentUser();
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        showFlushBar(context, e.message!);
      }
    } finally {
      NavigationService.instance.hideLoaderOverlay();
    }
  }

  Future<void> getCurrentUser({bool? showLoader = false}) async {
    try {
      if (showLoader!) {
        NavigationService.instance.showLoaderOverlay();
      }
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final snapshot = await FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: currentUser.uid).get();
        if (snapshot.docs.isEmpty) {
          _currentUser = null;
          return;
        }
        UserModel user = UserModel.fromJson(snapshot.docs.first.data());
        _currentUser = user;
        notifyListeners();
      }
    } finally {
      NavigationService.instance.hideLoaderOverlay();
    }
  }

  Future<void> register(BuildContext context, String email, String password) async {
    try {
      NavigationService.instance.showLoaderOverlay();

      if (!email.isValidEmail) {
        showFlushBar(context, 'Please enter a valid email address');
        debugPrint('Invalid email format');
        return;
      }
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final UserModel newUser = UserModel(
        email: email,
        uid: userCredential.user!.uid,
        active: true,
      );
      await FirebaseFirestore.instance.collection('users').doc(email).set(newUser.toJson());
      await getCurrentUser();
    } on FirebaseException catch (e) {
      if (context.mounted) {
        showFlushBar(context, '${e.message}');
      }
    } finally {
      NavigationService.instance.hideLoaderOverlay();
    }
  }
}
