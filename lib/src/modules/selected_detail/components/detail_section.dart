import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../../common/utils/helpers.dart';
import '../../common/utils/notify.dart';

/// 抽屉内的分区。
///
/// 对应 design/tokens.css 的 `.drawer-section`：顶部一条分隔线，
/// 小号大写分组标题，下面是内容。
class DetailSection extends StatelessWidget {
  /// 构造函数
  const DetailSection({
    super.key,
    required this.title,
    required this.children,
    this.bordered = true,
  });

  /// 分组标题
  final String title;

  /// 分区内容
  final List<Widget> children;

  /// 顶部是否画分隔线
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (bordered) const SkDivider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SkTokens.sp5,
            SkTokens.sp4,
            SkTokens.sp5,
            SkTokens.sp4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title.toUpperCase(),
                style: SkText.overline(context, color: c.ink3),
              ),
              const SizedBox(height: SkTokens.sp3),
              ...children,
            ],
          ),
        ),
      ],
    );
  }
}

/// 抽屉内的键值对行。
///
/// 对应 design/tokens.css 的 `.kv`：左侧小号灰字标签，右侧对齐的值。
class DetailKvRow extends StatelessWidget {
  /// 构造函数
  const DetailKvRow({
    super.key,
    required this.label,
    this.value,
    this.trailing,
    this.mono = false,
  });

  /// 标签
  final String label;

  /// 值（等宽或常规字体）
  final String? value;

  /// 自定义的值区域（按钮、chip 等），优先于 [value]
  final Widget? trailing;

  /// 值是否使用等宽字体
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SkTokens.sp2),
      child: Row(
        children: [
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: c.ink3),
            ),
          ),
          const SizedBox(width: SkTokens.sp4),
          Expanded(
            child: trailing ??
                Text(
                  value ?? '',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: mono
                      ? SkText.mono(context, fontSize: 11, color: c.ink1)
                      : theme.textTheme.bodySmall?.copyWith(color: c.ink1),
                ),
          ),
        ],
      ),
    );
  }
}

/// 抽屉里的复制按钮。
///
/// 对应 design/tokens.css 的 `.icon-btn`：22×22 的无边框图标按钮，
/// 点击后把内容写入剪贴板并弹出提示。
class DetailCopyButton extends StatelessWidget {
  /// 构造函数
  const DetailCopyButton(
    this.content, {
    super.key,
  });

  /// 要复制的内容
  final String content;

  @override
  Widget build(BuildContext context) {
    final isMounted = context.mounted;

    return SkIconButton(
      icon: Icons.content_copy_outlined,
      size: 22,
      iconSize: 14,
      color: SkColors.of(context).ink3,
      tooltip: context.i18n('components:atoms.copiedToClipboard'),
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: content));
        if (isMounted) {
          // ignore: use_build_context_synchronously
          notify(context.i18n('components:atoms.copiedToClipboard'));
        }
      },
    );
  }
}
