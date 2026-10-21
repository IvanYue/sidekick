import 'package:flutter/material.dart';

/// 设计令牌（Design Tokens）。
///
/// 唯一真值来自 `design/tokens.css`，Flutter 端 1:1 映射：
/// CSS 变量 `--sp-4` → [SkTokens.sp4]，`--r-lg` → [SkTokens.rLg]。
/// 改视觉时优先改这里，而不是散落在页面里的魔法数字。
class SkTokens {
  const SkTokens._();

  // ---------------------------------------------------------------------------
  // 间距刻度
  // ---------------------------------------------------------------------------
  static const double sp1 = 4;
  static const double sp2 = 6;
  static const double sp3 = 8;
  static const double sp4 = 12;
  static const double sp5 = 16;
  static const double sp6 = 20;
  static const double sp7 = 24;
  static const double sp8 = 32;
  static const double sp9 = 40;
  static const double sp10 = 48;

  // ---------------------------------------------------------------------------
  // 圆角
  // ---------------------------------------------------------------------------
  static const double rXs = 4;
  static const double rSm = 6;
  static const double rMd = 8;
  static const double rLg = 12;
  static const double rXl = 16;
  static const double rFull = 999;

  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(rXs));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(rSm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(rMd));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(rLg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(rXl));
  static const BorderRadius radiusFull =
      BorderRadius.all(Radius.circular(rFull));

  // ---------------------------------------------------------------------------
  // 结构尺寸
  // ---------------------------------------------------------------------------
  static const double titleBarHeight = 44;
  static const double topBarHeight = 56;
  static const double sidebarWidth = 232;
  static const double drawerWidth = 372;
  static const double controlHeight = 32;
  static const double controlHeightSm = 26;
  static const double iconButtonSize = 28;
  static const double tileSize = 40;
  static const double tileSizeLg = 48;

  // ---------------------------------------------------------------------------
  // 动效
  // ---------------------------------------------------------------------------
  static const Duration durFast = Duration(milliseconds: 120);
  static const Duration dur = Duration(milliseconds: 180);
  static const Duration durSlow = Duration(milliseconds: 280);
  static const Curve ease = Cubic(0.32, 0.72, 0, 1);
}

/// 等宽字体与字阶辅助。
///
/// 字体角色与 design/tokens.css 的 Typography 段落一一对应：
/// Poppins（标题）、IBM Plex Sans（正文）、等宽栈（版本号 / 路径 / SHA）。
class SkText {
  const SkText._();

  /// 等宽字体栈：优先 JetBrains Mono，缺失时回落系统等宽字体。
  static const List<String> monoFallback = [
    'JetBrains Mono',
    'SF Mono',
    'Menlo',
    'Courier New',
    'monospace',
  ];

  /// 等宽文本样式，12px / 行高 18px。
  static TextStyle mono(
    BuildContext context, {
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'JetBrains Mono',
      fontFamilyFallback: monoFallback,
      fontSize: fontSize,
      height: fontSize == 12 ? 1.5 : 22 / fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// 强调版等宽文本，15px / 行高 22px。
  static TextStyle monoLg(
    BuildContext context, {
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    return mono(
      context,
      fontSize: 15,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// 分组小标签：10px、大写、字距 0.09em。
  static TextStyle overline(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return theme.textTheme.labelSmall!.copyWith(
      fontSize: 10,
      height: 14 / 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.9,
      color: color ?? theme.textTheme.labelSmall?.color,
    );
  }
}
