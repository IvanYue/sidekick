import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/constants.dart';
import 'package:sidekick/src/version.dart';
import 'package:sidekick/src/window_border.dart';

/// Sidekick 顶部标题栏。
///
/// 对应 design/tokens.css 的 `.titlebar`：左侧窗口按钮、居中品牌名、右侧操作。
/// 设置入口只在侧边栏底部提供，搜索浮层由快捷键唤出，「检查更新」在设置页里，
/// 标题栏里都不再重复。
class SkAppBar extends ConsumerWidget implements PreferredSizeWidget {
  /// 构造函数
  const SkAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(SkTokens.titleBarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SkTitleBar(
      leading: Platform.isMacOS ? const WindowButtons() : null,
      // 软件名放到标题栏正中
      center: const _TitleBrand(),
      centerWidth: 320,
      // 非 macOS 自绘窗口按钮要占着右上角；macOS 用系统交通灯，右侧留空
      actions: Platform.isMacOS ? null : const WindowButtons(),
    );
  }
}

/// 标题栏居中的品牌区：方形标记 + 软件名 + 版本号。
class _TitleBrand extends StatelessWidget {
  /// 构造函数
  const _TitleBrand();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = SkColors.of(context);

    return IgnorePointer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SkBrandMark(letter: 'S'),
          const SizedBox(width: SkTokens.sp3),
          Text(kAppTitle, style: theme.textTheme.titleSmall),
          const SizedBox(width: SkTokens.sp3),
          Text(
            packageVersion,
            style: SkText.mono(context, fontSize: 10, color: c.ink3),
          ),
        ],
      ),
    );
  }
}
