import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';
import 'package:sidekick/src/modules/compatibility_checks/compat.provider.dart';
import 'package:sidekick/src/modules/fvm/fvm.provider.dart';
import 'package:sidekick/src/modules/navigation/navigation.provider.dart';
import 'package:sidekick/src/modules/ohos/ohos.provider.dart';
import 'package:sidekick/src/modules/projects/projects.provider.dart';
import 'package:sidekick/src/modules/releases/releases.provider.dart';
import 'package:sidekick/src/modules/settings/settings.screen.dart';

/// 应用侧边栏。
///
/// 对应 design/index.html 的 `.sidebar`：上方是工作区导航，底部是设置入口
/// 与 FVM 缓存目录 / 环境状态。
class AppSidebar extends ConsumerWidget {
  /// 构造函数
  const AppSidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  /// 当前路由
  final NavigationRoutes currentRoute;

  /// 导航回调
  final ValueChanged<NavigationRoutes> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    final installedCount = ref.watch(releasesStateProvider).all.length;
    final projectCount = ref.watch(projectsProvider).length;
    final ohosCount = ref.watch(ohosBranchesProvider).value?.length ?? 0;
    final compat = ref.watch(compatProvider);

    void openSettings() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingsScreen(),
        ),
      );
    }

    return SkSidebar(
      groups: [
        SkNavGroup(
          label: context.i18n('modules:common.navGroupWorkspace'),
          items: [
            SkNavItem(
              label: context.i18n('modules:common.navButtonInstalled'),
              icon: Icons.inventory_2_outlined,
              count: '$installedCount',
              selected: currentRoute == NavigationRoutes.homeScreen,
              onTap: () => onNavigate(NavigationRoutes.homeScreen),
            ),
            SkNavItem(
              label: context.i18n('modules:common.navButtonProjects'),
              icon: Icons.folder_outlined,
              count: '$projectCount',
              selected: currentRoute == NavigationRoutes.projectsScreen,
              onTap: () => onNavigate(NavigationRoutes.projectsScreen),
            ),
            SkNavItem(
              label: context.i18n('modules:common.navButtonReleases'),
              icon: Icons.layers_outlined,
              selected: currentRoute == NavigationRoutes.exploreScreen,
              onTap: () => onNavigate(NavigationRoutes.exploreScreen),
            ),
            SkNavItem(
              label: context.i18n('modules:ohos.navButtonOhos'),
              icon: Icons.phone_android_outlined,
              count: '$ohosCount',
              selected: currentRoute == NavigationRoutes.ohosScreen,
              onTap: () => onNavigate(NavigationRoutes.ohosScreen),
            ),
          ],
        ),
      ],
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkNavButton(
            item: SkNavItem(
              label: context.i18n('modules:common.navButtonSettings'),
              icon: Icons.settings_outlined,
              onTap: openSettings,
            ),
          ),
          const SizedBox(height: SkTokens.sp4),
          Row(
            children: [
              Icon(Icons.folder_outlined, size: 14, color: c.ink3),
              const SizedBox(width: SkTokens.sp3),
              Expanded(
                child: Text(
                  _shortenPath(fvmContext.versionsCachePath),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: c.ink3),
                ),
              ),
              const SizedBox(width: SkTokens.sp2),
              SkChip(
                label: compat.waiting
                    ? context.i18n('modules:common.sidebarChecking')
                    : compat.ready
                        ? context.i18n('modules:common.sidebarReady')
                        : context.i18n('modules:common.sidebarMissingComponents'),
                tone: compat.waiting
                    ? SkChipTone.neutral
                    : compat.ready
                        ? SkChipTone.ok
                        : SkChipTone.warn,
                dot: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 把用户主目录替换成 `~`，让路径在窄侧栏里也能完整显示。
String _shortenPath(String path) {
  final home = Platform.environment['HOME'] ??
      Platform.environment['USERPROFILE'] ??
      '';
  if (home.isEmpty || !path.startsWith(home)) return path;
  return '~${path.substring(home.length)}';
}
