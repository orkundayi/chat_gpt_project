import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

mixin DialogComposer {
  Flushbar showFlushBar(BuildContext context, String message, [Duration? duration]) {
    final ThemeData themeData = Theme.of(context);
    return Flushbar(
      isDismissible: true,
      positionOffset: 100.0,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      backgroundColor: themeData.colorScheme.onPrimary.withOpacity(0.1),
      messageText: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: themeData.colorScheme.onPrimary,
        ),
      ),
      duration: duration ?? const Duration(milliseconds: 3000),
    )..show(context);
  }
}
