import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../../../components/mdi_icons.dart';
import '../../common/utils/helpers.dart';
import '../../ide/components/open_in_ide_button.dart';
import '../../settings/settings.provider.dart';
import '../project.dto.dart';
import 'components/assets_tab.dart';
import 'components/detail_widgets.dart';
import 'components/overview_tab.dart';
import 'components/packages_tab.dart';
import 'components/version_tab.dart';
import 'project_detail.provider.dart';
import 'project_details.dart';

/// 项目详情的分区
enum ProjectDetailTab {
  /// 图标、描述、Flutter 版本、平台
  overview,

  /// 依赖及其最新版本
  packages,

  /// 资源浏览器
  assets,

  /// 应用版本
  version,
}

/// 项目详情页，展示在「项目」分区内。
///
/// 对应设计系统的页头规范：左上返回按钮 + 大标题 + 右侧操作，
/// 下方是 190px 宽的 tab 列表 + 竖分隔线 + 内容区。
class ProjectDetailScreen extends HookConsumerWidget {
  /// 构造函数
  const ProjectDetailScreen(
    this.project, {
    this.initialTab = ProjectDetailTab.overview,
    super.key,
  });

  /// 项目
  final FlutterProject project;

  /// 首个展示的 tab
  final ProjectDetailTab initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = useState(initialTab);
    final details = ref.watch(projectDetailsProvider(project.path));
    final settings = ref.watch(sidekickSettingsProvider);

    void close() => ref.read(selectedProjectProvider.notifier).state = null;

    // tab 项：选中态用 accentSoft 底 + accent 文字
    Widget tabItem(ProjectDetailTab value, IconData icon, String label) {
      return _TabItem(
        icon: icon,
        label: label,
        selected: tab.value == value,
        onTap: () => tab.value = value,
      );
    }

    Widget content(ProjectDetails details) {
      switch (tab.value) {
        case ProjectDetailTab.overview:
          return OverviewTab(project: project, details: details);
        case ProjectDetailTab.packages:
          return PackagesTab(details: details);
        case ProjectDetailTab.assets:
          return AssetsTab(details: details);
        case ProjectDetailTab.version:
          return VersionTab(details: details);
      }
    }

    final version = details.value?.rawVersion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 页头：返回按钮 + 标题 + 右侧操作
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SkTokens.sp7,
            SkTokens.sp7,
            SkTokens.sp8,
            0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkIconButton(
                icon: Icons.arrow_back,
                tooltip: context.i18n('modules:projects.detail.back'),
                onPressed: close,
              ),
              const SizedBox(width: SkTokens.sp4),
              Expanded(
                child: SkPageHeader(
                  title: project.name,
                  actions: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (version != null) ...[
                        VersionChip(version),
                        const SizedBox(width: SkTokens.sp4),
                      ],
                      SkIconButton(
                        icon: MdiIcons.folder,
                        tooltip: context.i18n('modules:projects.components.open'),
                        onPressed: () => OpenFile.open(project.path),
                      ),
                      OpenInSelectedIdeButton(project.path, settings),
                      OpenInIdeMenu(project.path, settings),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SkTokens.sp6),

        // 主体：tab 列表 + 竖分隔线 + 内容
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 190,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SkTokens.sp3,
                    vertical: SkTokens.sp1,
                  ),
                  children: [
                    tabItem(
                      ProjectDetailTab.overview,
                      MdiIcons.informationOutline,
                      context.i18n('modules:projects.detail.overview'),
                    ),
                    tabItem(
                      ProjectDetailTab.packages,
                      Icons.inventory_2_outlined,
                      context.i18n('modules:projects.detail.packages'),
                    ),
                    tabItem(
                      ProjectDetailTab.assets,
                      Icons.photo_library_outlined,
                      context.i18n('modules:projects.detail.assets'),
                    ),
                    tabItem(
                      ProjectDetailTab.version,
                      Icons.label_outline,
                      context.i18n('modules:projects.detail.version'),
                    ),
                  ],
                ),
              ),
              Container(width: 1, color: SkColors.of(context).lineSoft),
              Expanded(
                child: details.when(
                  data: content,
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => DetailMessage(
                    icon: Icons.error_outline,
                    message: context.i18n(
                      'modules:projects.detail.couldNotReadPubspec',
                      variables: {'error': error.toString()},
                    ),
                    action: SkButton(
                      label: context.i18n('modules:projects.detail.retry'),
                      onPressed: () =>
                          ref.invalidate(projectDetailsProvider(project.path)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 详情页左侧的 tab 项，选中态用 accentSoft 底 + accent 文字。
class _TabItem extends StatelessWidget {
  /// 构造函数
  const _TabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  /// 图标
  final IconData icon;

  /// 文案
  final String label;

  /// 是否选中
  final bool selected;

  /// 点击回调
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);
    final fg = selected ? c.accent : c.ink2;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: SkTokens.radiusSm,
          hoverColor: c.bgHover,
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: SkTokens.sp3),
            decoration: BoxDecoration(
              color: selected ? c.accentSoft : Colors.transparent,
              borderRadius: SkTokens.radiusSm,
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: SkTokens.sp3),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: fg,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 项目名旁的版本标签。
class VersionChip extends StatelessWidget {
  /// 构造函数
  const VersionChip(this.version, {super.key});

  /// 版本号
  final String version;

  @override
  Widget build(BuildContext context) {
    return SkChip(label: 'v$version', mono: true);
  }
}