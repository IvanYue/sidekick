import 'package:flutter/material.dart';

/// 颜色令牌。
///
/// 唯一真值来自 `design/tokens.css` 的 `:root` 与 `[data-theme="light"]`。
/// 以 ThemeExtension 的形式挂到 ThemeData 上，页面统一用
/// `SkColors.of(context).xxx` 取色，禁止再写死具体色值。
@immutable
class SkColors extends ThemeExtension<SkColors> {
  const SkColors({
    required this.bgApp,
    required this.bgSidebar,
    required this.bgPanel,
    required this.bgRaised,
    required this.bgInset,
    required this.bgOverlay,
    required this.bgHover,
    required this.bgActive,
    required this.line,
    required this.lineSoft,
    required this.lineStrong,
    required this.ink1,
    required this.ink2,
    required this.ink3,
    required this.inkInverse,
    required this.accent,
    required this.accentHover,
    required this.accentSoft,
    required this.accentLine,
    required this.onAccent,
    required this.info,
    required this.infoSoft,
    required this.infoLine,
    required this.ok,
    required this.okSoft,
    required this.okLine,
    required this.warn,
    required this.warnSoft,
    required this.warnLine,
    required this.danger,
    required this.dangerSoft,
    required this.dangerLine,
  });

  // ---------------------------------------------------------------------------
  // 底色
  // ---------------------------------------------------------------------------
  final Color bgApp;
  final Color bgSidebar;
  final Color bgPanel;
  final Color bgRaised;
  final Color bgInset;
  final Color bgOverlay;
  final Color bgHover;
  final Color bgActive;

  // ---------------------------------------------------------------------------
  // 描边
  // ---------------------------------------------------------------------------
  final Color line;
  final Color lineSoft;
  final Color lineStrong;

  // ---------------------------------------------------------------------------
  // 文字
  // ---------------------------------------------------------------------------
  final Color ink1;
  final Color ink2;
  final Color ink3;
  final Color inkInverse;

  // ---------------------------------------------------------------------------
  // 强调色（陶土橙）
  // ---------------------------------------------------------------------------
  final Color accent;
  final Color accentHover;
  final Color accentSoft;
  final Color accentLine;
  final Color onAccent;

  // ---------------------------------------------------------------------------
  // 语义色
  // ---------------------------------------------------------------------------
  final Color info;
  final Color infoSoft;
  final Color infoLine;
  final Color ok;
  final Color okSoft;
  final Color okLine;
  final Color warn;
  final Color warnSoft;
  final Color warnLine;
  final Color danger;
  final Color dangerSoft;
  final Color dangerLine;

  /// 深色主题（默认）：暖中性石墨底 + 陶土橙 / 灰蓝 / 橄榄绿三色强调。
  static const SkColors dark = SkColors(
    bgApp: Color(0xFF121110),
    bgSidebar: Color(0xFF161513),
    bgPanel: Color(0xFF1B1A17),
    bgRaised: Color(0xFF232120),
    bgInset: Color(0xFF0D0C0B),
    bgOverlay: Color(0xB80A0908),
    bgHover: Color(0x0CF0EEE9),
    bgActive: Color(0x13F0EEE9),
    line: Color(0xFF2B2925),
    lineSoft: Color(0xFF22201D),
    lineStrong: Color(0xFF3A3733),
    ink1: Color(0xFFF0EEE9),
    ink2: Color(0xFFA5A199),
    ink3: Color(0xFF74706A),
    inkInverse: Color(0xFF141311),
    accent: Color(0xFFD97757),
    accentHover: Color(0xFFE2886B),
    accentSoft: Color(0x24D97757),
    accentLine: Color(0x57D97757),
    onAccent: Color(0xFF1A0E08),
    info: Color(0xFF6A9BCC),
    infoSoft: Color(0x246A9BCC),
    infoLine: Color(0x4D6A9BCC),
    ok: Color(0xFF8A9A5B),
    okSoft: Color(0x248A9A5B),
    okLine: Color(0x4D8A9A5B),
    warn: Color(0xFFC99A3E),
    warnSoft: Color(0x24C99A3E),
    warnLine: Color(0x52C99A3E),
    danger: Color(0xFFD0574F),
    dangerSoft: Color(0x24D0574F),
    dangerLine: Color(0x52D0574F),
  );

  /// 浅色主题：骨白纸感 + 同一组三色强调。
  static const SkColors light = SkColors(
    bgApp: Color(0xFFF2F0EB),
    bgSidebar: Color(0xFFFAF8F4),
    bgPanel: Color(0xFFFFFEFB),
    bgRaised: Color(0xFFF4F1EB),
    bgInset: Color(0xFFEAE6DE),
    bgOverlay: Color(0x6B1C1A16),
    bgHover: Color(0x09141311),
    bgActive: Color(0x0F141311),
    line: Color(0xFFE2DED4),
    lineSoft: Color(0xFFECE8E0),
    lineStrong: Color(0xFFCDC8BC),
    ink1: Color(0xFF191816),
    ink2: Color(0xFF5F5A52),
    ink3: Color(0xFF8D877D),
    inkInverse: Color(0xFFF7F5F0),
    accent: Color(0xFFB85C3C),
    accentHover: Color(0xFFA55134),
    accentSoft: Color(0x1AB85C3C),
    accentLine: Color(0x47B85C3C),
    onAccent: Color(0xFFFFF8F4),
    info: Color(0xFF4A7FB5),
    infoSoft: Color(0x1A4A7FB5),
    infoLine: Color(0x424A7FB5),
    ok: Color(0xFF5F7445),
    okSoft: Color(0x1A5F7445),
    okLine: Color(0x425F7445),
    warn: Color(0xFF8A6412),
    warnSoft: Color(0x1A8A6412),
    warnLine: Color(0x428A6412),
    danger: Color(0xFFB23A33),
    dangerSoft: Color(0x1AB23A33),
    dangerLine: Color(0x42B23A33),
  );

  /// 取当前主题的颜色令牌。
  static SkColors of(BuildContext context) {
    return Theme.of(context).extension<SkColors>() ?? dark;
  }

  @override
  SkColors copyWith({
    Color? bgApp,
    Color? bgSidebar,
    Color? bgPanel,
    Color? bgRaised,
    Color? bgInset,
    Color? bgOverlay,
    Color? bgHover,
    Color? bgActive,
    Color? line,
    Color? lineSoft,
    Color? lineStrong,
    Color? ink1,
    Color? ink2,
    Color? ink3,
    Color? inkInverse,
    Color? accent,
    Color? accentHover,
    Color? accentSoft,
    Color? accentLine,
    Color? onAccent,
    Color? info,
    Color? infoSoft,
    Color? infoLine,
    Color? ok,
    Color? okSoft,
    Color? okLine,
    Color? warn,
    Color? warnSoft,
    Color? warnLine,
    Color? danger,
    Color? dangerSoft,
    Color? dangerLine,
  }) {
    return SkColors(
      bgApp: bgApp ?? this.bgApp,
      bgSidebar: bgSidebar ?? this.bgSidebar,
      bgPanel: bgPanel ?? this.bgPanel,
      bgRaised: bgRaised ?? this.bgRaised,
      bgInset: bgInset ?? this.bgInset,
      bgOverlay: bgOverlay ?? this.bgOverlay,
      bgHover: bgHover ?? this.bgHover,
      bgActive: bgActive ?? this.bgActive,
      line: line ?? this.line,
      lineSoft: lineSoft ?? this.lineSoft,
      lineStrong: lineStrong ?? this.lineStrong,
      ink1: ink1 ?? this.ink1,
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      inkInverse: inkInverse ?? this.inkInverse,
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      accentSoft: accentSoft ?? this.accentSoft,
      accentLine: accentLine ?? this.accentLine,
      onAccent: onAccent ?? this.onAccent,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      infoLine: infoLine ?? this.infoLine,
      ok: ok ?? this.ok,
      okSoft: okSoft ?? this.okSoft,
      okLine: okLine ?? this.okLine,
      warn: warn ?? this.warn,
      warnSoft: warnSoft ?? this.warnSoft,
      warnLine: warnLine ?? this.warnLine,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      dangerLine: dangerLine ?? this.dangerLine,
    );
  }

  @override
  SkColors lerp(ThemeExtension<SkColors>? other, double t) {
    if (other is! SkColors) return this;
    return SkColors(
      bgApp: Color.lerp(bgApp, other.bgApp, t)!,
      bgSidebar: Color.lerp(bgSidebar, other.bgSidebar, t)!,
      bgPanel: Color.lerp(bgPanel, other.bgPanel, t)!,
      bgRaised: Color.lerp(bgRaised, other.bgRaised, t)!,
      bgInset: Color.lerp(bgInset, other.bgInset, t)!,
      bgOverlay: Color.lerp(bgOverlay, other.bgOverlay, t)!,
      bgHover: Color.lerp(bgHover, other.bgHover, t)!,
      bgActive: Color.lerp(bgActive, other.bgActive, t)!,
      line: Color.lerp(line, other.line, t)!,
      lineSoft: Color.lerp(lineSoft, other.lineSoft, t)!,
      lineStrong: Color.lerp(lineStrong, other.lineStrong, t)!,
      ink1: Color.lerp(ink1, other.ink1, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      ink3: Color.lerp(ink3, other.ink3, t)!,
      inkInverse: Color.lerp(inkInverse, other.inkInverse, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentLine: Color.lerp(accentLine, other.accentLine, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      infoLine: Color.lerp(infoLine, other.infoLine, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
      okSoft: Color.lerp(okSoft, other.okSoft, t)!,
      okLine: Color.lerp(okLine, other.okLine, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      warnSoft: Color.lerp(warnSoft, other.warnSoft, t)!,
      warnLine: Color.lerp(warnLine, other.warnLine, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      dangerLine: Color.lerp(dangerLine, other.dangerLine, t)!,
    );
  }
}
