import 'package:flutter/material.dart';

import '../colors.dart';
import '../tokens.dart';

/// 按钮语义变体，对应 design/tokens.css 的 .btn-* 系列。
enum SkButtonVariant { primary, secondary, ghost, danger }

/// 按钮尺寸。
enum SkButtonSize { sm, md }

/// 徽章语义色。
enum SkChipTone { neutral, accent, ok, warn, danger, info }

/// 设计系统按钮。
class SkButton extends StatelessWidget {
  /// 构造函数
  const SkButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = SkButtonVariant.secondary,
    this.size = SkButtonSize.md,
    this.expand = false,
    this.busy = false,
  });

  /// 按钮文案
  final String label;

  /// 点击回调，为空时按钮置灰
  final VoidCallback? onPressed;

  /// 前置图标
  final IconData? icon;

  /// 语义变体
  final SkButtonVariant variant;

  /// 尺寸
  final SkButtonSize size;

  /// 是否撑满父级宽度
  final bool expand;

  /// 是否处于加载中
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);
    final isSmall = size == SkButtonSize.sm;
    final height = isSmall ? SkTokens.controlHeightSm : SkTokens.controlHeight;
    final radius = isSmall ? SkTokens.radiusSm : SkTokens.radiusMd;

    var bg = c.bgRaised;
    var fg = c.ink1;
    var border = c.line;
    switch (variant) {
      case SkButtonVariant.primary:
        bg = c.accent;
        fg = c.onAccent;
        border = Colors.transparent;
      case SkButtonVariant.secondary:
        bg = c.bgRaised;
        fg = c.ink1;
        border = c.line;
      case SkButtonVariant.ghost:
        bg = Colors.transparent;
        fg = c.ink2;
        border = Colors.transparent;
      case SkButtonVariant.danger:
        bg = c.dangerSoft;
        fg = c.danger;
        border = c.dangerLine;
    }

    final enabled = onPressed != null && !busy;
    final textColor = enabled ? fg : c.ink3;

    final content = Container(
      height: height,
      // 不能设 alignment：它会让 Container 在 loose 约束下撑满父级宽度
      width: expand ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 14),
      decoration: BoxDecoration(
        color: enabled ? bg : c.bgRaised,
        borderRadius: radius,
        border: Border.all(
          color: enabled ? border : c.lineSoft,
        ),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (busy) ...[
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                color: textColor,
              ),
            ),
            const SizedBox(width: SkTokens.sp2),
          ],
          if (icon != null) ...[
            Icon(icon, size: isSmall ? 13 : 15, color: textColor),
            const SizedBox(width: SkTokens.sp2),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: radius,
        hoverColor: c.bgHover,
        child: content,
      ),
    );
  }
}

/// 设计系统图标按钮。
class SkIconButton extends StatelessWidget {
  /// 构造函数
  const SkIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = SkTokens.iconButtonSize,
    this.iconSize = 18,
    this.color,
    this.active = false,
  });

  /// 图标
  final IconData icon;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 悬浮提示
  final String? tooltip;

  /// 按钮尺寸
  final double size;

  /// 图标尺寸
  final double iconSize;

  /// 图标颜色
  final Color? color;

  /// 是否处于激活态
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: SkTokens.radiusMd,
        hoverColor: c.bgHover,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? c.bgRaised : Colors.transparent,
            borderRadius: SkTokens.radiusMd,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: color ?? (active ? c.ink1 : c.ink2),
          ),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// 设计系统徽章 / 状态标签。
class SkChip extends StatelessWidget {
  /// 构造函数
  const SkChip({
    super.key,
    required this.label,
    this.tone = SkChipTone.neutral,
    this.outline = false,
    this.dot = false,
    this.icon,
    this.mono = false,
  });

  /// 文本
  final String label;

  /// 语义色
  final SkChipTone tone;

  /// 是否只描边不填充
  final bool outline;

  /// 是否带前置圆点
  final bool dot;

  /// 前置图标
  final IconData? icon;

  /// 是否使用等宽字体
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    var fg = c.ink2;
    var bg = c.bgRaised;
    var border = c.line;
    switch (tone) {
      case SkChipTone.neutral:
        fg = c.ink2;
        bg = c.bgRaised;
        border = c.line;
      case SkChipTone.accent:
        fg = c.accent;
        bg = c.accentSoft;
        border = c.accentLine;
      case SkChipTone.ok:
        fg = c.ok;
        bg = c.okSoft;
        border = c.okLine;
      case SkChipTone.warn:
        fg = c.warn;
        bg = c.warnSoft;
        border = c.warnLine;
      case SkChipTone.danger:
        fg = c.danger;
        bg = c.dangerSoft;
        border = c.dangerLine;
      case SkChipTone.info:
        fg = c.info;
        bg = c.infoSoft;
        border = c.infoLine;
    }

    final textStyle = mono
        ? SkText.mono(context, fontSize: 11, color: fg)
        : theme.textTheme.labelSmall?.copyWith(color: fg);

    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: SkTokens.sp2),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : bg,
        borderRadius: SkTokens.radiusSm,
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: SkTokens.sp2),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: SkTokens.sp1),
          ],
          Text(
            label,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// 分段筛选控件，取代原生 DropdownButton。
class SkSegmented extends StatelessWidget {
  /// 构造函数
  const SkSegmented({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onChanged,
  });

  /// 选项
  final List<String> items;

  /// 选中项下标
  final int selectedIndex;

  /// 选中变化回调
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    return Container(
      height: SkTokens.controlHeight,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: c.bgInset,
        borderRadius: SkTokens.radiusMd,
        border: Border.all(color: c.lineSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++)
            GestureDetector(
              onTap: onChanged == null ? null : () => onChanged!(i),
              child: AnimatedContainer(
                duration: SkTokens.durFast,
                curve: SkTokens.ease,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: SkTokens.sp4),
                decoration: BoxDecoration(
                  color: i == selectedIndex ? c.bgRaised : Colors.transparent,
                  borderRadius: SkTokens.radiusSm,
                  border: Border.all(
                    color: i == selectedIndex ? c.line : Colors.transparent,
                  ),
                ),
                child: Text(
                  items[i],
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: i == selectedIndex ? c.ink1 : c.ink3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 设计系统开关。
class SkSwitch extends StatelessWidget {
  /// 构造函数
  const SkSwitch({
    super.key,
    required this.value,
    this.onChanged,
  });

  /// 当前值
  final bool value;

  /// 变化回调
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);

    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: SkTokens.durFast,
        curve: SkTokens.ease,
        width: 32,
        height: 18,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? c.accent : c.bgRaised,
          borderRadius: SkTokens.radiusFull,
          border: Border.all(
            color: value ? Colors.transparent : c.lineStrong,
          ),
        ),
        child: AnimatedAlign(
          duration: SkTokens.durFast,
          curve: SkTokens.ease,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: value ? c.onAccent : c.ink3,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// 设计系统下拉选择，取代原生 DropdownButton。
class SkSelect extends StatelessWidget {
  /// 构造函数
  const SkSelect({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.width,
  });

  /// 当前值
  final String value;

  /// 可选项
  final List<String> items;

  /// 变化回调
  final ValueChanged<String>? onChanged;

  /// 控件宽度
  final double? width;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    final field = Container(
      height: SkTokens.controlHeight,
      padding: const EdgeInsets.symmetric(horizontal: SkTokens.sp4),
      decoration: BoxDecoration(
        color: c.bgRaised,
        borderRadius: SkTokens.radiusMd,
        border: Border.all(color: c.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(color: c.ink1),
            ),
          ),
          const SizedBox(width: SkTokens.sp2),
          Icon(Icons.keyboard_arrow_down, size: 14, color: c.ink3),
        ],
      ),
    );

    return SizedBox(
      width: width,
      child: PopupMenuButton<String>(
        initialValue: value,
        onSelected: onChanged,
        tooltip: '',
        position: PopupMenuPosition.under,
        elevation: 6,
        color: c.bgRaised,
        shape: const RoundedRectangleBorder(
          borderRadius: SkTokens.radiusMd,
        ),
        itemBuilder: (context) => [
          for (final item in items)
            PopupMenuItem<String>(
              value: item,
              height: 30,
              child: Text(
                item,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: item == value ? c.accent : c.ink1,
                ),
              ),
            ),
        ],
        child: field,
      ),
    );
  }
}

/// 键盘按键提示。
///
/// 对应 design/tokens.css 的 `.kbd`。
class SkKbd extends StatelessWidget {
  /// 构造函数
  const SkKbd({
    super.key,
    required this.label,
  });

  /// 按键文本
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.bgRaised,
        borderRadius: SkTokens.radiusXs,
        border: Border.all(color: c.line),
      ),
      child: Text(
        label,
        style: SkText.mono(context, fontSize: 10, color: c.ink3),
      ),
    );
  }
}

/// 搜索输入框。
class SkSearchField extends StatelessWidget {
  /// 构造函数
  const SkSearchField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.width,
    this.autofocus = false,
  });

  /// 输入控制器
  final TextEditingController? controller;

  /// 占位文案
  final String? hint;

  /// 输入变化回调
  final ValueChanged<String>? onChanged;

  /// 提交回调
  final ValueChanged<String>? onSubmitted;

  /// 控件宽度
  final double? width;

  /// 是否自动聚焦
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    return Container(
      height: SkTokens.controlHeight,
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: SkTokens.sp3),
      decoration: BoxDecoration(
        color: c.bgRaised,
        borderRadius: SkTokens.radiusMd,
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 14, color: c.ink3),
          const SizedBox(width: SkTokens.sp2),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: theme.textTheme.bodySmall?.copyWith(color: c.ink1),
              cursorColor: c.accent,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                hintText: hint,
                hintStyle: theme.textTheme.bodySmall?.copyWith(color: c.ink3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
