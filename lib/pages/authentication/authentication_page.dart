import 'package:flutter/material.dart';

import '../../utils/mixin/dialog_composer.dart';
import 'login_page.dart';
import 'register_page.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({Key? key}) : super(key: key);

  @override
  AuthenticationPageState createState() => AuthenticationPageState();
}

class AuthenticationPageState extends State<AuthenticationPage> with SingleTickerProviderStateMixin, DialogComposer {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showLogin = true;

  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleView() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _showLogin = !_showLogin;
      if (_showLogin) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
      if (_showLogin) {
        _emailController.clear();
        _passwordController.clear();
      } else {
        _emailController.clear();
        _passwordController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: themeData.colorScheme.secondary,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Authentication",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: themeData.colorScheme.primaryContainer,
      ),
      body: Stack(
        children: [
          IgnorePointer(
            ignoring: !_showLogin,
            child: LoginPage(
              emailController: _emailController,
              passwordController: _passwordController,
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: IgnorePointer(
              ignoring: _showLogin,
              child: RegisterPage(
                emailController: _emailController,
                passwordController: _passwordController,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: themeData.colorScheme.primaryContainer,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _showLogin ? "Don't have an account?" : "Already have an account?",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      floatingActionButton: InkWell(
        onTap: _toggleView,
        child: CircleAvatar(
          radius: 40.0,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _showLogin ? "Register" : "Login",
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
