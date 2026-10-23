import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../components/mdi_icons.dart';
import '../../../modules/common/dto/release.dto.dart';
import '../../fvm/fvm_queue.provider.dart';
import '../../ohos/ohos.constants.dart';
import '../../ohos/ohos.service.dart';
import '../project.dto.dart';

/// 项目卡片里的 Flutter 版本选择器。
///
/// 对应 design/tokens.css 的 `.proj-version`：单个 26px 高的胶囊（不是
/// 套在另一个方框里），等宽字体显示当前锁定版本 + 下拉箭头，点开是带
/// OHOS 标记的版本列表。
class ProjectReleaseSelect extends ConsumerWidget {
  /// 构造函数
  const ProjectReleaseSelect({
    required this.project,
    required this.releases,
    super.key,
  });

  /// 项目
  final FlutterProject project;

  /// 可选版本
  final List<ReleaseDto> releases;

  /// 当前锁定版本的显示文案：OHOS 锁定显示短名而不是原始分支名。
  String _pinnedLabel(BuildContext context) {
    final pinned = project.pinnedVersion;
    if (pinned == null) {
      return context.i18n('modules:projects.choose');
    }

    return ohosBranchPattern.hasMatch(pinned.nameWithAlias.split('/').last)
        ? ohosDisplayName(pinned.nameWithAlias)
        : pinned.nameWithAlias;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      tooltip: context.i18n(
        'modules:projects.components.selectAFlutterSdkVersion',
      ),
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      onSelected: (version) async {
        await ref
            .read(fvmQueueProvider.notifier)
            .pinVersion(context, project, version);
      },
      itemBuilder: (context) {
        return releases
            .map(
              (version) => PopupMenuItem(
                value: version.name,
                height: 34,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        version.isOhosSdk
                            ? ohosDisplayName(version.name)
                            : version.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    // 在选择器里区分 OHOS SDK
                    if (version.isOhosSdk) ...[
                      const SizedBox(width: SkTokens.sp2),
                      Icon(Icons.phone_android, size: 12, color: c.ok),
                    ],
                  ],
                ),
              ),
            )
            .toList();
      },
      child: Container(
        height: SkTokens.controlHeightSm,
        padding: const EdgeInsets.symmetric(horizontal: SkTokens.sp3),
        constraints: const BoxConstraints(maxWidth: 165),
        decoration: BoxDecoration(
          color: c.bgRaised,
          borderRadius: SkTokens.radiusSm,
          border: Border.all(color: c.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _pinnedLabel(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SkText.mono(context, fontSize: 11, color: c.ink1),
              ),
            ),
            const SizedBox(width: SkTokens.sp2),
            Icon(MdiIcons.menuDown, size: 14, color: c.ink3),
          ],
        ),
      ),
    );
  }
}
