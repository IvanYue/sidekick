import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/constants.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';
import 'package:sidekick/src/modules/navigation/navigation.provider.dart';
import 'package:sidekick/src/modules/settings/settings.screen.dart';
import 'package:sidekick/src/modules/updater/components/update_button.dart';
import 'package:sidekick/src/version.dart';
import 'package:sidekick/src/window_border.dart';

/// Sidekick 顶部标题栏。
///
/// 对应 design/tokens.css 的 `.titlebar`：三段式 —— 左侧品牌、居中搜索、右侧操作。
class SkAppBar extends ConsumerWidget implements PreferredSizeWidget {
  /// 构造函数
  const SkAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(SkTokens.titleBarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 打开设置页
    void openSettingsScreen() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingsScreen(),
        ),
      );
    }

    // 打开搜索浮层
    void openSearchModal() {
      ref.read(navigationProvider.notifier).goTo(NavigationRoutes.searchScreen);
    }

    final theme = Theme.of(context);
    final c = SkColors.of(context);

    return SkTitleBar(
      leading: Platform.isMacOS ? const WindowButtons() : null,
      brand: IgnorePointer(
        child: Row(
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
      ),
      center: _TitleSearchField(onTap: openSearchModal),
      actions: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SkUpdateButton(),
          SkIconButton(
            icon: Icons.settings_outlined,
            tooltip: context.i18n('modules:common.navButtonSettings'),
            onPressed: openSettingsScreen,
          ),
          if (!Platform.isMacOS) const WindowButtons(),
        ],
      ),
    );
  }
}

/// 标题栏居中的搜索入口。
///
/// 只做视觉展示，点击后打开全局搜索浮层。
class _TitleSearchField extends StatelessWidget {
  /// 构造函数
  const _TitleSearchField({required this.onTap});

  /// 点击回调
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: SkTokens.radiusSm,
        hoverColor: c.bgHover,
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: SkTokens.sp3),
          decoration: BoxDecoration(
            color: c.bgRaised,
            borderRadius: SkTokens.radiusSm,
            border: Border.all(color: c.line),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 14, color: c.ink3),
              const SizedBox(width: SkTokens.sp2),
              Expanded(
                child: Text(
                  context.i18n('modules:search.components.search'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: c.ink3),
                ),
              ),
              const SkKbd(label: '⌘'),
              const SizedBox(width: SkTokens.sp1),
              const SkKbd(label: 'K'),
            ],
          ),
        ),
      ),
    );
  }
}
