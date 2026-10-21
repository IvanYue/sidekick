import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';
import 'package:sidekick/src/modules/settings/settings.provider.dart';

import '../../../components/mdi_icons.dart';
import '../../../components/molecules/version_install_button.dart';
import '../../ide/components/open_in_ide_button.dart';
import '../../navigation/navigation.provider.dart';
import '../../ohos/ohos.constants.dart';
import '../../releases/releases.provider.dart';
import '../../sandbox/sandbox.screen.dart';
import '../detail/project_detail.provider.dart';
import '../project.dto.dart';
import 'project_actions.dart';
import 'project_release_select.dart';

/// 项目卡片。
///
/// 对应 design/index.html 的 `.proj-card`：图标瓦片 + 名称（含 OHOS 徽章）
/// + 描述 + 路径 + 底部操作行（管理 / Playground / IDE / 版本选择器）。
class ProjectListItem extends ConsumerWidget {
  /// 构造函数
  const ProjectListItem(
    this.project, {
    this.versionSelect = false,
    super.key,
  });

  /// Flutter 项目
  final FlutterProject project;

  /// 是否显示版本选择器
  final bool versionSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (project.invalid) return UnavailableProjectItem(project);

    final c = SkColors.of(context);
    final theme = Theme.of(context);

    final cachedVersions = ref.watch(releasesStateProvider).all;

    final version =
        ref.watch(getVersionProvider(project.pinnedVersion?.nameWithAlias));

    final needInstall = version != null && project.pinnedVersion != null;

    final sidekickSettings = ref.watch(settingsProvider).sidekick;

    // 钉定在 OHOS SDK 上：显示 OHOS 徽章（fork 安装与手动克隆的顶层检出都覆盖）
    final isOhos = project.pinnedVersion?.fork == kOhosForkName ||
        version?.isOhosSdk == true;

    void openProjectPlayground() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SandboxScreen(
            project: project,
          ),
        ),
      );
    }

    void openDetail() {
      ref.read(selectedProjectProvider.notifier).state = project.path;
      // 卡片也出现在搜索结果中
      ref
          .read(navigationProvider.notifier)
          .goTo(NavigationRoutes.projectsScreen);
    }

    return SizedBox(
      height: 208,
      child: _ProjCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 头部：图标 + 名称 + 平台说明 + 更多操作
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProjectIconTile(project: project),
                const SizedBox(width: SkTokens.sp3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              project.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          if (isOhos) ...[
                            const SizedBox(width: SkTokens.sp2),
                            SkChip(
                              label: context.i18n('modules:ohos.ohosTag'),
                              tone: SkChipTone.ok,
                              icon: Icons.phone_android,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.i18n('modules:projects.flutterProject'),
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                ProjectActions(project),
              ],
            ),
            const SizedBox(height: SkTokens.sp4),
            // 描述
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: c.ink2),
            ),
            const SizedBox(height: SkTokens.sp3),
            // 路径
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: c.ink3),
                const SizedBox(width: SkTokens.sp2),
                Expanded(
                  child: Text(
                    shortenHome(project.path),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SkText.mono(context, fontSize: 11, color: c.ink3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SkTokens.sp4),
            const SkDivider(),
            const SizedBox(height: SkTokens.sp3),
            // 底部操作行
            Row(
              children: [
                SkIconButton(
                  icon: MdiIcons.tune,
                  tooltip: context.i18n('modules:projects.detail.manage'),
                  onPressed: openDetail,
                ),
                SkIconButton(
                  icon: MdiIcons.consoleLine,
                  tooltip: context.i18n(
                    'modules:projects.components.openTerminalPlayground',
                  ),
                  onPressed: openProjectPlayground,
                ),
                OpenInSelectedIdeButton(project.path, sidekickSettings),
                OpenInIdeMenu(project.path, sidekickSettings),
                const SizedBox(width: SkTokens.sp3),
                // 版本区右对齐，用 Expanded 吸收剩余宽度以避免窄卡片溢出
                if (versionSelect)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (needInstall) VersionInstallButton(version),
                          // 版本选择器（`.proj-version` 胶囊）
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 190),
                            child: _VersionPill(
                              child: ProjectReleaseSelect(
                                project: project,
                                releases: cachedVersions,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 项目卡片容器（`.proj-card`：bgPanel 底 + line 描边 + radiusLg + sp5 内边距）。
class _ProjCard extends StatelessWidget {
  /// 构造函数
  const _ProjCard({required this.child, this.dangerBorder = false});

  /// 内容
  final Widget child;

  /// 是否使用危险色描边（项目不可用）
  final bool dangerBorder;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);

    return Container(
      padding: const EdgeInsets.all(SkTokens.sp5),
      decoration: BoxDecoration(
        color: c.bgPanel,
        borderRadius: SkTokens.radiusLg,
        border: Border.all(color: dangerBorder ? c.dangerLine : c.line),
      ),
      child: child,
    );
  }
}

/// 项目图标瓦片（`.tile-40`）：有项目图标时显示图标，否则退回 Flutter 标记。
class _ProjectIconTile extends StatelessWidget {
  /// 构造函数
  const _ProjectIconTile({required this.project});

  /// 项目
  final FlutterProject project;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);

    final icon = project.cachedIcon ??
        FutureBuilder<Widget>(
          future: project.icon,
          builder: (context, snapshot) {
            if (snapshot.hasData) return snapshot.data!;
            return const SizedBox.shrink();
          },
        );

    return Container(
      width: SkTokens.tileSize,
      height: SkTokens.tileSize,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.bgRaised,
        borderRadius: SkTokens.radiusLg,
        border: Border.all(color: c.lineSoft),
      ),
      child: icon,
    );
  }
}

/// 版本选择器胶囊（`.proj-version`）。
class _VersionPill extends StatelessWidget {
  /// 构造函数
  const _VersionPill({required this.child});

  /// 内容（版本选择器）
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);

    return Container(
      height: SkTokens.controlHeightSm,
      padding: const EdgeInsets.only(left: SkTokens.sp3),
      decoration: BoxDecoration(
        color: c.bgRaised,
        borderRadius: SkTokens.radiusSm,
        border: Border.all(color: c.line),
      ),
      child: child,
    );
  }
}

/// 项目加载失败的原因文案。
String projectLoadErrorMessage(BuildContext context, FlutterProject project) {
  switch (project.loadError) {
    case ProjectLoadError.notFound:
      return context.i18n('modules:projects.components.folderNotFound');
    case ProjectLoadError.missingPubspec:
      return context.i18n('modules:projects.components.pubspecNotFound');
    case ProjectLoadError.notFlutter:
      return context.i18n('modules:projects.notAFlutterProject');
    case ProjectLoadError.unreadable:
    case null:
      return context.i18n(
        'modules:projects.couldNotReadProject',
        variables: {'error': project.loadErrorDetails ?? ''},
      );
  }
}

/// 无法加载的已保存项目卡片。
///
/// 仍然展示该项目，让用户知道它为什么消失并能移除它，而不是让它静默消失。
class UnavailableProjectItem extends ConsumerWidget {
  /// 构造函数
  const UnavailableProjectItem(this.project, {super.key});

  /// 无法加载的项目
  final FlutterProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    return _ProjCard(
      dangerBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: SkTokens.tileSize,
                height: SkTokens.tileSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.dangerSoft,
                  borderRadius: SkTokens.radiusLg,
                  border: Border.all(color: c.dangerLine),
                ),
                child: Icon(
                  Icons.folder_off_outlined,
                  size: 20,
                  color: c.danger,
                ),
              ),
              const SizedBox(width: SkTokens.sp3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      project.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    // 失败原因（如「未找到项目文件夹」），只渲染一次
                    Text(
                      projectLoadErrorMessage(context, project),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: c.danger,
                      ),
                    ),
                  ],
                ),
              ),
              ProjectActions(project),
            ],
          ),
          const SizedBox(height: SkTokens.sp4),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: c.ink3),
              const SizedBox(width: SkTokens.sp2),
              Expanded(
                child: Tooltip(
                  message: project.path,
                  child: Text(
                    project.path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SkText.mono(context, fontSize: 11, color: c.ink3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 把用户主目录替换成 `~`，让长路径在卡片里也能完整显示。
String shortenHome(String path) {
  final home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
  if (home.isEmpty || !path.startsWith(home)) return path;
  return '~${path.substring(home.length)}';
}
