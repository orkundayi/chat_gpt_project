import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateHelper {
  static String formatDate(DateTime date, BuildContext context, String? languageCode) {
    String pattern = (languageCode == 'tr') ? 'd MMMM y EEEE' : 'MMMM d, y EEEE';
    return DateFormat(pattern, languageCode).format(date);
  }
}
