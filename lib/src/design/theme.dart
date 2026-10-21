import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'tokens.dart';

/// Builds the app text theme.
///
/// Tests replace it so widget tests don't fetch fonts from Google Fonts.
@visibleForTesting
TextTheme Function([TextTheme? textTheme]) appTextTheme =
    GoogleFonts.ibmPlexSansTextTheme;

/// Builds the display text theme (Poppins).
///
/// Tests replace it so widget tests don't fetch fonts from Google Fonts.
@visibleForTesting
TextTheme Function([TextTheme? textTheme]) appDisplayTextTheme =
    GoogleFonts.poppinsTextTheme;

/// 构建新 UI 的主题。
///
/// 唯一真值来自 `design/tokens.css`：深色为默认（暖中性石墨底 + 陶土橙强调），
/// 浅色为骨白纸感。旧版的 deepOrange / cyan 主题已废弃。
ThemeData buildSkTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final c = isDark ? SkColors.dark : SkColors.light;
  final base = isDark ? ThemeData.dark() : ThemeData.light();

  final uiTheme = appTextTheme(base.textTheme);
  final displayTheme = appDisplayTextTheme(base.textTheme);

  final scheme =
      (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
    primary: c.accent,
    onPrimary: c.onAccent,
    primaryContainer: c.accentSoft,
    onPrimaryContainer: c.accent,
    secondary: c.info,
    onSecondary: c.ink1,
    tertiary: c.ok,
    onTertiary: c.ink1,
    error: c.danger,
    onError: c.onAccent,
    surface: c.bgApp,
    onSurface: c.ink1,
    surfaceContainerLowest: c.bgInset,
    surfaceContainerLow: c.bgSidebar,
    surfaceContainer: c.bgPanel,
    surfaceContainerHigh: c.bgRaised,
    surfaceContainerHighest: c.bgRaised,
    onSurfaceVariant: c.ink2,
    outline: c.lineStrong,
    outlineVariant: c.line,
    surfaceTint: c.accent,
  );

  final textTheme = _textTheme(uiTheme, displayTheme, c);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bgApp,
    canvasColor: c.bgApp,
    cardColor: c.bgPanel,
    dividerColor: c.line,
    dividerTheme: DividerThemeData(
      color: c.line,
      thickness: 1,
      space: 1,
    ),
    textTheme: textTheme,
    extensions: [c],
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: c.bgApp,
      foregroundColor: c.ink1,
      surfaceTintColor: Colors.transparent,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        disabledBackgroundColor: c.bgRaised,
        disabledForegroundColor: c.ink3,
        minimumSize: const Size(0, SkTokens.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: SkTokens.radiusMd,
        ),
        textStyle: textTheme.labelMedium,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: c.bgRaised,
        foregroundColor: c.ink1,
        disabledForegroundColor: c.ink3,
        minimumSize: const Size(0, SkTokens.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        side: BorderSide(color: c.line),
        shape: const RoundedRectangleBorder(
          borderRadius: SkTokens.radiusMd,
        ),
        textStyle: textTheme.labelMedium,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.ink2,
        minimumSize: const Size(0, SkTokens.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: SkTokens.radiusMd,
        ),
        textStyle: textTheme.labelMedium,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: c.ink2,
        minimumSize:
            const Size(SkTokens.iconButtonSize, SkTokens.iconButtonSize),
        shape: const RoundedRectangleBorder(
          borderRadius: SkTokens.radiusMd,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.bgRaised,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      hintStyle: textTheme.bodySmall?.copyWith(color: c.ink3),
      border: const OutlineInputBorder(
        borderRadius: SkTokens.radiusMd,
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: SkTokens.radiusMd,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: SkTokens.radiusMd,
        borderSide: BorderSide(color: c.accentLine),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.bgPanel,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: SkTokens.radiusXl,
      ),
      titleTextStyle: textTheme.titleMedium,
      contentTextStyle: textTheme.bodyMedium,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: c.bgRaised,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: SkTokens.radiusMd,
      ),
      textStyle: textTheme.bodySmall,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: c.bgInset,
        borderRadius: SkTokens.radiusSm,
        border: Border.all(color: c.line),
      ),
      textStyle: textTheme.bodySmall?.copyWith(color: c.ink1),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.bgRaised,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: c.ink1),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: SkTokens.radiusMd,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.accent,
      linearTrackColor: c.bgRaised,
      circularTrackColor: c.bgRaised,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? c.onAccent : c.ink3,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? c.accent : c.bgRaised,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.transparent
            : c.lineStrong,
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: c.ink2,
      textColor: c.ink1,
      titleTextStyle: textTheme.bodyMedium?.copyWith(color: c.ink1),
      subtitleTextStyle: textTheme.bodySmall,
      shape: const RoundedRectangleBorder(
        borderRadius: SkTokens.radiusMd,
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(c.lineStrong),
      radius: const Radius.circular(SkTokens.rFull),
      thickness: const WidgetStatePropertyAll(6),
    ),
  );
}

TextTheme _textTheme(TextTheme ui, TextTheme display, SkColors c) {
  return ui.copyWith(
    displaySmall: display.displaySmall?.copyWith(
      fontSize: 26,
      height: 32 / 26,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.22,
      color: c.ink1,
    ),
    headlineSmall: display.headlineSmall?.copyWith(
      fontSize: 19,
      height: 26 / 19,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.14,
      color: c.ink1,
    ),
    titleLarge: display.titleLarge?.copyWith(
      fontSize: 17,
      height: 24 / 17,
      fontWeight: FontWeight.w600,
      color: c.ink1,
    ),
    titleMedium: ui.titleMedium?.copyWith(
      fontSize: 15,
      height: 22 / 15,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.06,
      color: c.ink1,
    ),
    titleSmall: ui.titleSmall?.copyWith(
      fontSize: 13,
      height: 19 / 13,
      fontWeight: FontWeight.w600,
      color: c.ink1,
    ),
    bodyMedium: ui.bodyMedium?.copyWith(
      fontSize: 13,
      height: 20 / 13,
      fontWeight: FontWeight.w400,
      color: c.ink2,
    ),
    bodySmall: ui.bodySmall?.copyWith(
      fontSize: 12,
      height: 18 / 12,
      fontWeight: FontWeight.w400,
      color: c.ink2,
    ),
    labelMedium: ui.labelMedium?.copyWith(
      fontSize: 12,
      height: 18 / 12,
      fontWeight: FontWeight.w500,
      color: c.ink2,
    ),
    labelSmall: ui.labelSmall?.copyWith(
      fontSize: 11,
      height: 16 / 11,
      fontWeight: FontWeight.w400,
      color: c.ink3,
    ),
  );
}
