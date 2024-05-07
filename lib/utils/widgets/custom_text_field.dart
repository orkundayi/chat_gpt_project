import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final bool obscureText;
  final TextEditingController? controller;
  const CustomTextField({
    Key? key,
    required this.labelText,
    this.obscureText = false,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        color: colorScheme.onPrimary,
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: colorScheme.primary,
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: colorScheme.onPrimary.withOpacity(0.4),
            width: 1.0,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: colorScheme.onPrimary.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: colorScheme.onPrimary,
            width: 2.0,
          ),
        ),
        labelStyle: TextStyle(color: colorScheme.onPrimary, fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}
