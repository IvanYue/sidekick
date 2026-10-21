import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'design/theme.dart';

export 'design/theme.dart' show appDisplayTextTheme, appTextTheme;

/// 深色主题（默认）：暖中性石墨底 + 陶土橙强调。
ThemeData get darkTheme => buildSkTheme(Brightness.dark);

/// 浅色主题：骨白纸感。
ThemeData get lightTheme => buildSkTheme(Brightness.light);

bool isNumeric(String? s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

double getWindowsBuild() {
  final osVer =
      Platform.operatingSystemVersion.replaceAll(RegExp(r'[^\w\s\.]+'), '');

  final splitOsVer = osVer.split(' ');

  final nums = splitOsVer.where((element) => isNumeric(element)).toList();
  return double.parse(nums.last);
}

Color platformBackgroundColor(BuildContext context) {
  final themeBrightness = Theme.of(context).brightness;
  final platformBrightness = MediaQuery.of(context).platformBrightness;
  final brightnessMatches = themeBrightness == platformBrightness;

  // Brightness matches doesn't work on Windows 10

  if (Platform.isWindows) {
    if (getWindowsBuild() >= 22000) {
      Window.setEffect(
          effect: WindowEffect.mica,
          color: Theme.of(context).cardColor.withAlpha(0),
          dark: Theme.of(context).brightness == Brightness.dark);
      return Colors.transparent;
    } else if (getWindowsBuild() >= 10240) {
      // Acrylic causes issues on W10
      Window.setEffect(
        effect: WindowEffect.aero,
        color: Theme.of(context).cardColor.withAlpha(200),
      );
      return Colors.transparent;
    }
    return Theme.of(context).cardColor;
  }

  if (brightnessMatches && Platform.isMacOS) {
    Window.setEffect(
      effect: WindowEffect.sidebar,
      color: Colors.transparent,
    );
    return Colors.transparent;
  } else {
    return Theme.of(context).cardColor;
  }
}
