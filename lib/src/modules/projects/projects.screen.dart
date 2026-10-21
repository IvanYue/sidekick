import 'package:file_selector/file_selector.dart' as selector;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../components/mdi_icons.dart';
import '../../modules/common/utils/notify.dart';
import '../settings/settings.provider.dart';
import 'components/project_list_item.dart';
import 'components/projects_empty.dart';
import 'detail/project_detail.provider.dart';
import 'detail/project_detail.screen.dart';
import 'projects.provider.dart';
import 'projects.service.dart';

/// 项目页。
///
/// 对应 design/index.html 的 `#page-projects`：页头（含 FVM Only 开关、
/// 刷新、添加项目）+ 响应式项目卡片网格。
class ProjectsScreen extends HookConsumerWidget {
  /// 构造函数
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(projectsProvider.notifier);
    final projects = ref.watch(projectsProvider);
    final settings = ref.watch(settingsProvider);

    final filteredProjects = useState(projects);
    final refreshing = useState(false);

    Future<void> onRefresh() async {
      if (refreshing.value) return;
      refreshing.value = true;
      try {
        await ref.read(projectsProvider.notifier).refresh();
        notify(
          // ignore: use_build_context_synchronously
          context.i18n('modules:projects.projectsRefreshed'),
        );
      } finally {
        if (context.mounted) refreshing.value = false;
      }
    }

    Future<void> handleChooseDirectory() async {
      final directoryPath = await selector.getDirectoryPath(
        confirmButtonText: context.i18n('modules:projects.choose'),
      );
      if (directoryPath == null) {
        // 用户取消了选择
        return;
      }
      // ignore: use_build_context_synchronously
      await notifier.addProject(context, directoryPath);
    }

    useEffect(() {
      if (settings.sidekick.onlyProjectsWithFvm) {
        filteredProjects.value =
            // 保留不可用的项目，方便用户移除
            projects.where((p) => p.invalid || p.pinnedVersion != null).toList();
      } else {
        filteredProjects.value = [...projects];
      }
      return;
    }, [projects, settings.sidekick]);

    final selectedPath = ref.watch(selectedProjectProvider);
    final selected = selectedPath == null
        ? null
        : projects
            .where((p) => !p.invalid && isSameProjectPath(p.path, selectedPath))
            .firstOrNull;

    // 清除已被移除或变得不可用的选中项，避免它在重新加载后自动打开
    final staleSelection = selectedPath != null && selected == null;
    useEffect(() {
      if (staleSelection) {
        Future.microtask(() {
          if (context.mounted) {
            ref.read(selectedProjectProvider.notifier).state = null;
          }
        });
      }
      return null;
    }, [staleSelection]);

    if (selected != null) {
      return ProjectDetailScreen(selected, key: ValueKey(selected.path));
    }

    return SkPage(
      title: context.i18n('modules:projects.projects'),
      description: context.i18n(
        'modules:projects.projectsProjects',
        variables: {'projects': projects.length},
      ),
      actions: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: context.i18n(
              'modules:projects.onlyDisplayProjectsThatHaveVersionsPinned',
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.i18n('modules:projects.fvmOnly'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: SkTokens.sp3),
                SkSwitch(
                  value: settings.sidekick.onlyProjectsWithFvm,
                  onChanged: (value) {
                    settings.sidekick.onlyProjectsWithFvm = value;
                    ref.read(settingsProvider.notifier).save(settings);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: SkTokens.sp3),
          _RefreshIconButton(busy: refreshing.value, onPressed: onRefresh),
          const SizedBox(width: SkTokens.sp3),
          SkButton(
            label: context.i18n('modules:projects.addProject'),
            icon: MdiIcons.plus,
            variant: SkButtonVariant.primary,
            onPressed: handleChooseDirectory,
          ),
        ],
      ),
      child: projects.isEmpty
          ? const EmptyProjects()
          : ResponsiveGridList(
              desiredItemWidth: 290,
              minSpacing: SkTokens.sp5,
              scroll: false,
              children: filteredProjects.value.map((project) {
                return ProjectListItem(
                  project,
                  versionSelect: true,
                  key: Key(project.path),
                );
              }).toList(),
            ),
    );
  }
}

/// 刷新图标按钮：空闲时是图标按钮，刷新中显示进度圈。
class _RefreshIconButton extends StatelessWidget {
  /// 构造函数
  const _RefreshIconButton({required this.busy, required this.onPressed});

  /// 是否正在刷新
  final bool busy;

  /// 点击回调
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final label = context.i18n('components:atoms.refresh');

    if (busy) {
      return Tooltip(
        message: label,
        child: SizedBox(
          width: SkTokens.iconButtonSize,
          height: SkTokens.iconButtonSize,
          child: Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: c.accent),
            ),
          ),
        ),
      );
    }

    return SkIconButton(
      icon: MdiIcons.refresh,
      tooltip: label,
      onPressed: () => onPressed(),
    );
  }
}