import 'package:flutter/material.dart';

import '../colors.dart';
import '../tokens.dart';
import 'controls.dart';

/// 面板容器。
class SkPanel extends StatelessWidget {
  /// 构造函数
  const SkPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(SkTokens.sp5),
    this.flush = false,
  });

  /// 内容
  final Widget child;

  /// 内边距，flush 为 true 时忽略
  final EdgeInsetsGeometry padding;

  /// 是否去掉背景与描边
  final bool flush;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);

    if (flush) {
      return SizedBox(width: double.infinity, child: child);
    }

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: c.bgPanel,
        borderRadius: SkTokens.radiusLg,
        border: Border.all(color: c.line),
      ),
      child: child,
    );
  }
}

/// 面板标题栏。
class SkPanelHeader extends StatelessWidget {
  /// 构造函数
  const SkPanelHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(
      horizontal: SkTokens.sp6,
      vertical: SkTokens.sp4,
    ),
  });

  /// 标题
  final String title;

  /// 副标题
  final String? subtitle;

  /// 右侧操作
  final Widget? trailing;

  /// 内边距
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.lineSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: SkTokens.sp1),
                  Text(
                    subtitle!,
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 细分隔线。
class SkDivider extends StatelessWidget {
  /// 构造函数
  const SkDivider({super.key, this.indent = 0, this.strong = false});

  /// 左侧缩进
  final double indent;

  /// 是否使用强描边色
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    return Container(
      height: 1,
      margin: EdgeInsets.only(left: indent),
      color: strong ? c.line : c.lineSoft,
    );
  }
}

/// 列表行。
class SkListRow extends StatelessWidget {
  /// 构造函数
  const SkListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.dense = false,
  });

  /// 左侧内容
  final Widget? leading;

  /// 主标题
  final Widget title;

  /// 次行说明
  final Widget? subtitle;

  /// 右侧操作
  final Widget? trailing;

  /// 点击回调
  final VoidCallback? onTap;

  /// 是否选中
  final bool selected;

  /// 是否紧凑排版
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? SkTokens.sp5 : SkTokens.sp6,
        vertical: dense ? SkTokens.sp3 : SkTokens.sp4,
      ),
      color: selected ? c.bgActive : Colors.transparent,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: SkTokens.sp4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                title,
                if (subtitle != null) ...[
                  const SizedBox(height: SkTokens.sp1),
                  subtitle!,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: SkTokens.sp4),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: c.bgHover,
        child: content,
      ),
    );
  }
}

/// 提示条：左侧竖条 + 图标 + 标题 + 说明。
class SkNoteBar extends StatelessWidget {
  /// 构造函数
  const SkNoteBar({
    super.key,
    this.icon,
    this.title,
    this.description,
    this.trailing,
    this.tone = SkChipTone.accent,
  });

  /// 图标
  final IconData? icon;

  /// 标题
  final String? title;

  /// 说明
  final String? description;

  /// 右侧操作
  final Widget? trailing;

  /// 语义色
  final SkChipTone tone;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    var toneColor = c.accent;
    switch (tone) {
      case SkChipTone.neutral:
        toneColor = c.ink3;
      case SkChipTone.accent:
        toneColor = c.accent;
      case SkChipTone.ok:
        toneColor = c.ok;
      case SkChipTone.warn:
        toneColor = c.warn;
      case SkChipTone.danger:
        toneColor = c.danger;
      case SkChipTone.info:
        toneColor = c.info;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.bgPanel,
        borderRadius: SkTokens.radiusLg,
        border: Border.all(color: c.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 3, color: toneColor),
            const SizedBox(width: SkTokens.sp4),
            if (icon != null) ...[
              Icon(icon, size: 20, color: toneColor),
              const SizedBox(width: SkTokens.sp4),
            ],
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: SkTokens.sp4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: theme.textTheme.titleSmall,
                      ),
                    if (description != null) ...[
                      const SizedBox(height: SkTokens.sp1),
                      Text(
                        description!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: SkTokens.sp4),
              // 缩放兜底：窄窗口下宁可把右侧内容整体缩小，也不要撑破提示条
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: trailing!,
                ),
              ),
              const SizedBox(width: SkTokens.sp4),
            ],
          ],
        ),
      ),
    );
  }
}

/// 空态 / 错误态。
class SkEmptyState extends StatelessWidget {
  /// 构造函数
  const SkEmptyState({
    super.key,
    this.icon,
    this.title,
    this.description,
    this.action,
    this.tone = SkChipTone.neutral,
  });

  /// 图标
  final IconData? icon;

  /// 标题
  final String? title;

  /// 说明
  final String? description;

  /// 主操作
  final Widget? action;

  /// 语义色
  final SkChipTone tone;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    var iconColor = c.ink3;
    var iconBg = c.bgRaised;
    var iconBorder = c.line;
    switch (tone) {
      case SkChipTone.neutral:
        iconColor = c.ink3;
        iconBg = c.bgRaised;
        iconBorder = c.line;
      case SkChipTone.accent:
        iconColor = c.accent;
        iconBg = c.accentSoft;
        iconBorder = c.accentLine;
      case SkChipTone.ok:
        iconColor = c.ok;
        iconBg = c.okSoft;
        iconBorder = c.okLine;
      case SkChipTone.warn:
        iconColor = c.warn;
        iconBg = c.warnSoft;
        iconBorder = c.warnLine;
      case SkChipTone.danger:
        iconColor = c.danger;
        iconBg = c.dangerSoft;
        iconBorder = c.dangerLine;
      case SkChipTone.info:
        iconColor = c.info;
        iconBg = c.infoSoft;
        iconBorder = c.infoLine;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: SkTokens.radiusXl,
            border: Border.all(color: iconBorder),
          ),
          child: icon == null ? null : Icon(icon, size: 24, color: iconColor),
        ),
        const SizedBox(width: SkTokens.sp5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: theme.textTheme.titleMedium,
                ),
              if (description != null) ...[
                const SizedBox(height: SkTokens.sp2),
                Text(
                  description!,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: SkTokens.sp5),
          action!,
        ],
      ],
    );
  }
}

/// 信息卡：标签 + 数值 + 说明。
class SkStatTile extends StatelessWidget {
  /// 构造函数
  const SkStatTile({
    super.key,
    this.label,
    this.value,
    this.hint,
    this.icon,
    this.trailing,
  });

  /// 标签
  final String? label;

  /// 数值
  final String? value;

  /// 补充说明
  final String? hint;

  /// 图标
  final IconData? icon;

  /// 右侧内容
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SkTokens.sp5),
      decoration: BoxDecoration(
        color: c.bgPanel,
        borderRadius: SkTokens.radiusLg,
        border: Border.all(color: c.line),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: SkTokens.tileSize,
              height: SkTokens.tileSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.accentSoft,
                borderRadius: SkTokens.radiusLg,
                border: Border.all(color: c.accentLine),
              ),
              child: Icon(icon, size: 18, color: c.accent),
            ),
            const SizedBox(width: SkTokens.sp5),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label != null)
                  Text(label!, style: theme.textTheme.labelSmall),
                if (value != null) ...[
                  const SizedBox(height: SkTokens.sp1),
                  Text(
                    value!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'JetBrains Mono',
                      fontFamilyFallback: SkText.monoFallback,
                    ),
                  ),
                ],
                if (hint != null) ...[
                  const SizedBox(height: SkTokens.sp1),
                  Text(hint!, style: theme.textTheme.labelSmall),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
