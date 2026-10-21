import 'package:flutter/material.dart';
import 'package:fvm/fvm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../components/mdi_icons.dart';
import '../projects.provider.dart';

/// 项目可执行的操作。
enum ProjectActionOptions {
  /// 打开项目目录
  openDirectory,

  /// 移除项目
  remove,
}

/// 项目行末尾的操作菜单。
///
/// 对应 design/tokens.css 的 `.icon-btn`：竖向三点图标按钮 + 下拉菜单。
class ProjectActions extends ConsumerWidget {
  /// 构造函数
  const ProjectActions(
    this.project, {
    super.key,
  });

  /// 项目
  final Project project;

  /// 渲染菜单项
  List<PopupMenuEntry<ProjectActionOptions>> renderMenuOptions(
      BuildContext context) {
    PopupMenuItem<ProjectActionOptions> item({
      required ProjectActionOptions value,
      required IconData icon,
      required String label,
    }) {
      return PopupMenuItem(
        value: value,
        height: 34,
        child: Row(
          children: [
            Icon(icon, size: 15),
            const SizedBox(width: SkTokens.sp3),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    return [
      item(
        value: ProjectActionOptions.openDirectory,
        label: context.i18n('modules:projects.components.open'),
        icon: MdiIcons.openInNew,
      ),
      item(
        value: ProjectActionOptions.remove,
        label: context.i18n('modules:projects.components.remove'),
        icon: MdiIcons.delete,
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = SkColors.of(context);

    return PopupMenuButton<ProjectActionOptions>(
      tooltip: '',
      onSelected: (result) {
        if (result == ProjectActionOptions.remove) {
          ref.read(projectsProvider.notifier).removeProject(project.path);
        }

        if (result == ProjectActionOptions.openDirectory) {
          OpenFile.open(
            project.path,
          );
        }
      },
      itemBuilder: (context) => renderMenuOptions(context),
      child: SizedBox(
        width: SkTokens.iconButtonSize,
        height: SkTokens.iconButtonSize,
        child: Icon(MdiIcons.dotsVertical, size: 18, color: c.ink2),
      ),
    );
  }
}