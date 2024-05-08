import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final Function()? onTap;
  final String? labelText;
  final bool obscureText;
  final TextEditingController? controller;
  final bool? expands;
  const CustomTextField({
    Key? key,
    this.labelText,
    this.obscureText = false,
    this.expands = false,
    this.onTap,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final onpressed = onTap ?? () {};
    return TextFormField(
      onTap: onpressed,
      minLines: expands ?? false ? null : 1,
      maxLines: expands ?? false ? null : 1,
      expands: expands ?? false,
      controller: controller,
      keyboardType: expands ?? false ? TextInputType.text : null,
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
