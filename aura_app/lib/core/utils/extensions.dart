import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  MediaQueryData get mq => MediaQuery.of(this);
  double get screenWidth => mq.size.width;
  double get screenHeight => mq.size.height;
  EdgeInsets get padding => mq.padding;
}

extension DateTimeX on DateTime {
  /// '2026-03' format for month_key.
  String get monthKey =>
      '${year.toString()}-${month.toString().padLeft(2, '0')}';
}
