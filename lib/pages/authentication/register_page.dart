import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../services/firebase_service.dart';
import '../../utils/mixin/dialog_composer.dart';
import '../../utils/widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  const RegisterPage({
    Key? key,
    required this.emailController,
    required this.passwordController,
  }) : super(key: key);

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> with DialogComposer {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            themeData.colorScheme.primary,
            themeData.colorScheme.secondary,
          ],
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                themeData.colorScheme.onPrimary,
                BlendMode.srcATop,
              ),
              child: Lottie.asset(
                'assets/lottie/auth.json',
                height: 150.0,
                width: 150.0,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32.0),
            CustomTextField(
              labelText: "Email",
              controller: widget.emailController,
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              labelText: "Password",
              obscureText: true,
              controller: widget.passwordController,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                final String email = widget.emailController.text.trim();
                final String password = widget.passwordController.text.trim();
                await context.read<FirebaseService>().register(context, email, password);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: themeData.colorScheme.primaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                "Register",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
